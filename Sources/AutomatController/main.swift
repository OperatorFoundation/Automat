//
//  AutomatListenerCommandLine.swift
//
//
//  Created by Dr. Brandon Wiley on 10/4/22.
//

import ArgumentParser
import Lifecycle
import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
#else
import FoundationNetworking
#endif

#if os(macOS) || os(iOS)
import os.log
#else
import Logging
#endif

import NIO

import Gardener
import KeychainCli
import Nametag
import Net
import Simulation
import Spacetime
import Transmission
import Universe

import Automat

@main
struct CommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "automat-controller",
        subcommands: [New.self, Run.self]
    )
}

extension CommandLine
{
    struct New: ParsableCommand
    {
        @Argument(help: "Port on which to run the listener")
        var port: Int

        mutating public func run() throws
        {
            let ip: String = try Ipify.getPublicIP()

            if let test = TransmissionConnection(host: ip, port: port)
            {
                test.close()

                throw NewCommandError.portInUse
            }

            guard let keychain = Keychain(baseDirectory: File.homeDirectory().appendingPathComponent(".automat-controller")) else
            {
                throw NewCommandError.couldNotLoadKeychain
            }

            guard let privateKeyKeyAgreement = keychain.generateAndSavePrivateKey(label: "AutomatController.KeyAgreement", type: .P256KeyAgreement) else
            {
                throw NewCommandError.couldNotGeneratePrivateKey
            }

            guard let nametag = Nametag() else
            {
                throw NewCommandError.nametagError
            }

            let privateIdentity = try PrivateIdentity(keyAgreement: privateKeyKeyAgreement, nametag: nametag)
            let publicIdentity = privateIdentity.publicIdentity

            let config = Config(name: name, host: ip, port: port, identity: publicIdentity)
            let encoder = JSONEncoder()
            let configData = try encoder.encode(config)
            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-controller-config.json")
            try configData.write(to: configURL)
            print("Wrote config to \(configURL.path)")
        }
    }
}

extension CommandLine
{
    struct Run: ParsableCommand
    {
        mutating func run() throws
        {
            #if os(macOS) || os(iOS)
            let logger = Logger(subsystem: "org.OperatorFoundation.AutomatController", category: "Persona")
            #else
            let logger = Logger(label: "org.OperatorFoundation.AutomatController")
            #endif

            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-controller-config.json")
            let configData = try Data(contentsOf: configURL)
            let decoder = JSONDecoder()
            let config = try decoder.decode(Config.self, from: configData)
            print("Read config from \(configURL.path)")

            let lifecycle = ServiceLifecycle()

            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            lifecycle.registerShutdown(label: "eventLoopGroup", .sync(eventLoopGroup.syncShutdownGracefully))

            let simulation = Simulation(capabilities: Capabilities(.display, .networkListen))
            let controller = AutomatController(config: config, logger: logger, effects: simulation.effects, events: simulation.events)

            lifecycle.register(label: "server", start: .sync(controller.start), shutdown: .sync(controller.shutdown))

            lifecycle.start
            {
                error in

                if let error = error
                {
                    logger.error("failed starting automat-controller ☠️: \(error)")
                }
                else
                {
                    logger.info("automat-controller started successfully 🚀")
                }
            }

            lifecycle.wait()
        }
    }
}

public enum NewCommandError: Error
{
    case portInUse
    case couldNotGeneratePrivateKey
    case couldNotLoadKeychain
    case nametagError
}

CommandLine.main()
