//
//  GameViewController.swift
//  ZiggiZag
//
//  Created by Cappillen on 2/11/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//


import UIKit
import QuartzCore
import SceneKit

//key person = player

//collision func for coin and player
struct bodyNames {
    static let Person = 0x1 << 1
    static let Coin = 0x1 << 2
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    //declare main variables
    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goinLeft = Bool()
    
    var tempBox = SCNNode()
    
    var prevBoxNumber = Int()
    
    var boxNumber = Int()
    
    var firstOne = Bool()
    
    var score = Int()
    var highscore = Int()
    
    var dead = Bool()
    
    var scoreLbl = UILabel()
    var highScoreLbl = UILabel()
    
    var gameButton = UIButton()
    var slow = Bool()
    var spd = Int()

    func fadeIn(node : SCNNode) {
        //fades in blocks
        node.opacity = 0
        node.runAction(SCNAction.fadeIn(duration: 0.5))
        
        
    }
    func fadeOut(node : SCNNode) {
        //fades out and drop blocks
        let move = SCNAction.move(to: SCNVector3Make(node.position.x, node.position.y - 2, node.position.z), duration: 0.5)
        node.runAction(move)
        node.runAction(SCNAction.fadeOut(duration: 0.5))
        
        
    }
    override func viewDidLoad() {
        //calls the scene for the first time in forever
        self.createScene()
        
        //draws text labels
        //declare score label
        scoreLbl = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5, width: self.view.frame.width, height: 100))
        scoreLbl.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - self.view.frame.height / 2.5)
        
        scoreLbl.textAlignment = .center
        
        scoreLbl.text = "Score: \(score)"
        scoreLbl.textColor = UIColor.darkGray
        self.view.addSubview(scoreLbl)
        //declare highscore label
        highScoreLbl = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5, width: self.view.frame.width, height: 100))
        highScoreLbl.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5)
        highScoreLbl.textAlignment = .center
        
        highScoreLbl.text = "Highscore: \(highscore)"
        highScoreLbl.textColor = UIColor.darkGray
        self.view.addSubview(highScoreLbl)
        
        //calls the pyshicsWorld func helps with collision with the coin and player
        scene.physicsWorld.contactDelegate = self
        
        //gamecenter stuff
        //doesn't work don't have developer account
        gameButton = UIButton(type: UIButtonType.custom)
        gameButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        gameButton.center = CGPoint(x: self.view.frame.width - 40, y: 60)
        gameButton.setImage(UIImage(named: "gamecenter"), for: .normal)
        gameButton.addTarget(self, action: #selector(GameViewController.slowspeed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(gameButton)
        
    }
    func slowspeed() {
        if slow == false {
            spd = 100
            slow = true
        } else {
            spd = 20
            slow = false
        }
    }
    func updateLabel() {
        //updates the text label everytime we hit a coin
        scoreLbl.text = "Score: \(score)"
        highScoreLbl.text = "Highscore: \(highscore)"
    
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //detects if the person and coin hit each other
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == bodyNames.Coin && nodeB.physicsBody?.categoryBitMask == bodyNames.Person {
            
            nodeA.removeFromParentNode()
            addScore()
            
        } else if nodeA.physicsBody?.categoryBitMask == bodyNames.Person && nodeB.physicsBody?.categoryBitMask == bodyNames.Coin {
            nodeB.removeFromParentNode()
            addScore()
            
        }
    }
    
    func addScore() {
        //changes score
        score += 1
        print(score)
        
        self.performSelector(onMainThread: #selector(GameViewController.updateLabel), with: nil, waitUntilDone: false)
        
        if score > highscore {
            highscore = score
            let scoreDefault = UserDefaults.standard
            scoreDefault.set(highscore, forKey: "highscore")
            print(highscore)
            
        }
    }
    
    func createCoin(box : SCNNode) {
        //creates coin
        scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0)
        let spin = SCNAction.rotate(by: CGFloat(M_PI * 2), around: SCNVector3Make(0, 0.5, 0.5), duration: 0.5)
        let randomNumber = arc4random() % 8
        if randomNumber == 3 {
            let coinScene = SCNScene(named: "coin.dae")
            let coin = coinScene?.rootNode.childNode(withName: "Coin", recursively: true)
            //puts the coin above the box
            coin?.position = SCNVector3Make(box.position.x, box.position.y + 1, box.position.z)
            coin?.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            //add physics to coin
            coin?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(node: coin!, options: nil))
            coin?.physicsBody?.categoryBitMask = bodyNames.Coin
            coin?.physicsBody?.contactTestBitMask = bodyNames.Person
            coin?.physicsBody?.collisionBitMask = bodyNames.Person
            coin?.physicsBody?.isAffectedByGravity = false
            //adds coin to scene
            scene.rootNode.addChildNode(coin!)
            coin?.runAction(SCNAction.repeatForever(spin))
            fadeIn(node: coin!)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //continous loop
        if dead == false {
        
        let deleteBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true)
        
        let currentBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber + 1)", recursively: true)
        //deletes box and creates new ones
        if (deleteBox?.position.x)! > person.position.x + 1 || (deleteBox?.position.z)! > person.position.z + 1 {
            
            prevBoxNumber += 1
            print("Prv: \(prevBoxNumber)")
            
            fadeOut(node: deleteBox!)
            
            createBox()
        }
        //if the person is off the path
        if person.position.x > (currentBox?.position.x)! - 0.5 && person.position.x < (currentBox?.position.x)! + 0.5 || person.position.z > (currentBox?.position.z)! - 0.5 && person.position.z < (currentBox?.position.z)! + 0.5 {
        
            //On platform
            
        } else {
            //recalls the createScene func, resets the game
            die()
            dead = true
            
        }
            
        }
    }
    
    func die() {
        //die scene
        //drops the player
        person.runAction(SCNAction.move(to: SCNVector3Make(person.position.x, person.position.y - 10, person.position.z), duration: 1.0))
        
        let wait = SCNAction.wait(duration: 1.2)
        //action that resets the game
        let sequence = SCNAction.sequence([wait, SCNAction.run({
            (node) in
            
            self.scene.rootNode.enumerateChildNodes({ (node, stop) in
                
                node.removeFromParentNode()
                
            })
            
        }), SCNAction.run({ (node) in
            self.createScene()
            self.firstBox.position = SCNVector3Make(0, 0, 0)
            self.firstBox.opacity = 1
        })])
        
        person.runAction(sequence)
        
    }
    
    func createBox() {
        //makes the box
        tempBox = SCNNode(geometry: firstBox.geometry)
        
        fadeIn(node: tempBox)
        
        let prevBox = scene.rootNode.childNode(withName: "\(boxNumber)", recursively: true)
        boxNumber += 1
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        //goin left or right
        switch randomNumber {
            
        case 0:
            //case goin right
            tempBox.position = SCNVector3Make((prevBox?.position.x)! - firstBox.scale.x, (prevBox?.position.y)!, (prevBox?.position.z)!)
            
            if firstOne == true {
                firstOne = false
                goinLeft = false
            }
            break
        case 1:
            //case goin left
            tempBox.position = SCNVector3Make((prevBox?.position.x)!, (prevBox?.position.y)!, (prevBox?.position.z)! - firstBox.scale.z)
            
            if firstOne == true {
                firstOne = false
                goinLeft = true
            }
            break
        default:
            //goin nowhere
            break
        }
        
        self.scene.rootNode.addChildNode(tempBox)
        //creates a coin on the box
        createCoin(box: tempBox)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //determines where the player moves
        if dead == false {
            if goinLeft == false {
                //goin right
                person.removeAllActions()
                person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-100, 0, 0), duration: TimeInterval(spd))))
                goinLeft = true
            
            } else {
                //goin left
                person.removeAllActions()
                person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(0, 0, -100), duration: TimeInterval(spd))))
                goinLeft = false

            }
        }
    }
    
    func createScene() {
        
        slow == false
        spd = 20
        //alse resets score just the label
        self.performSelector(onMainThread: #selector(GameViewController.updateLabel), with: nil, waitUntilDone: false)
        //reset score
        score = 0
        
        let scoreDefault = UserDefaults.standard
        
        if scoreDefault.integer(forKey: "highscore") != 0 {
            highscore = scoreDefault.integer(forKey: "highscore")
        } else {
            highscore = 0
        }
        
        print(highscore)
        
        boxNumber = 0
        prevBoxNumber = 0
        firstOne = true
        dead = false
        
        self.view.backgroundColor = UIColor.white
        
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = scene
        
        //Create Person
        let personGeo = SCNSphere(radius: 0.2)
        person = SCNNode(geometry: personGeo)
        let personMat = SCNMaterial()
        personMat.diffuse.contents = UIColor.red
        personGeo.materials = [personMat]
        person.position = SCNVector3Make(0, 1.1, 0)
        
        //Add physics to player
        person.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(node: person, options: nil))
        person.physicsBody?.categoryBitMask = bodyNames.Person
        person.physicsBody?.collisionBitMask = bodyNames.Coin
        person.physicsBody?.contactTestBitMask = bodyNames.Coin
        person.physicsBody?.isAffectedByGravity = false
        
        scene.rootNode.addChildNode(person)
        
        //Create Camera
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3Make(30, 30, 30)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: person)
        constraint.isGimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        person.addChildNode(cameraNode)
        
        //Create Box
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0)
        firstBoxGeo.materials = [boxMaterial]
        firstBox.geometry = firstBoxGeo
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(boxNumber)"
        firstBox.opacity = 1
        
        
        
        for i in 0...6 {
            
            createBox()
        }

        //Create Light
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.directional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = SCNLight.LightType.directional
        light2.eulerAngles = SCNVector3Make(45,-45, 0)
        scene.rootNode.addChildNode(light2)
        
        
    }
    
    
}
