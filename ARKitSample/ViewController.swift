//
//  ViewController.swift
//  ARKitSample
//
//  Created by Denis Malykh on 04.02.18.
//  Copyright © 2018 Yandex. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    var source: SCNAudioSource? = nil

    @IBOutlet private weak var arView: ARSCNView! {
        didSet {
            let rec = UITapGestureRecognizer(target: self, action: #selector(didTap))
            arView.addGestureRecognizer(rec)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        genSpheres(count: 10, divergence: 0.25, radiusFrom: 0.01, radiusTo: 0.05, colors: [
            .red, .white, .blue, .green, .yellow, .black, .orange
        ])

        source = SCNAudioSource(fileNamed: "ping.aif")
        source?.loops = false
        source?.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let conf = ARWorldTrackingConfiguration()
        arView.session.run(conf, options: [])

        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    private func addSphere(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = -0.2, radius: CGFloat = 0.01, color: UIColor = .white) {
        let geometry = SCNSphere(radius: radius)

        let mtrl = SCNMaterial()
        mtrl.diffuse.contents = color
        mtrl.locksAmbientWithDiffuse = true
        geometry.materials = [mtrl]

        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(x, y, z)

        arView.scene.rootNode.addChildNode(node)
    }

    private func genSpheres(count: Int, divergence: CGFloat, radiusFrom: CGFloat, radiusTo: CGFloat, colors: [UIColor]) {
        for _ in 0..<count {
            let xs = rnd(from: -divergence, to: divergence)
            let ys = rnd(from: -divergence, to: divergence)
            let zs = rnd(from: -divergence, to: divergence) - divergence
            let rd = rnd(from: radiusFrom, to: radiusTo)
            let clr = colors[Int(arc4random() % UInt32(colors.count))]
            addSphere(x: xs, y: ys, z: zs, radius: rd, color: clr)
        }
    }

    private func rnd(from: CGFloat, to: CGFloat) -> CGFloat {
        let diff = (to - from) * 100.0
        let rnd = arc4random() % UInt32(diff)
        return CGFloat(rnd) / 100.0 + from
    }

    @objc func didTap(_ rec: UITapGestureRecognizer) {
        let pt = rec.location(in: arView)
        let res = arView.hitTest(pt, options: [.boundingBoxOnly: true]).flatMap { $0.node }
        for node in res {
            node.removeFromParentNode()
        }
        if !res.isEmpty, let src = source {
            arView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: src))
        }
    }
}

