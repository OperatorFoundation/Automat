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

struct CommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "automat-pool",
        subcommands: [New.self, Run.self]
    )
}

extension CommandLine
{
    struct New: ParsableCommand
    {
        @Argument(help: "Human-readable name for your listener to use in invites")
        var name: String

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

            guard let keychain = Keychain(baseDirectory: File.homeDirectory().appendingPathComponent(".automat-pool")) else
            {
                throw NewCommandError.couldNotLoadKeychain
            }

            guard let privateKeyKeyAgreement = keychain.generateAndSavePrivateKey(label: "AutomatPool.KeyAgreement", type: .P256KeyAgreement) else
            {
                throw NewCommandError.couldNotGeneratePrivateKey
            }

            guard let nametag = Nametag() else
            {
                throw NewCommandError.nametagError
            }

            let config = ConnectionPoolConfig(host: ip, port: port)
            let encoder = JSONEncoder()
            let configData = try encoder.encode(config)
            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-pool-config.json")
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
            let logger = Logger(subsystem: "org.OperatorFoundation.AutomatConnectionPool", category: "Persona")
            #else
            let logger = Logger(label: "org.OperatorFoundation.AutomatConnectionPool")
            #endif
            
            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-pool-config.json")
            let configData = try Data(contentsOf: configURL)
            let decoder = JSONDecoder()
            let config = try decoder.decode(ConnectionPoolConfig.self, from: configData)
            print("Read config from \(configURL.path)")

            let lifecycle = ServiceLifecycle()

            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            lifecycle.registerShutdown(label: "eventLoopGroup", .sync(eventLoopGroup.syncShutdownGracefully))

            let simulation = Simulation(capabilities: Capabilities(.display, .networkListen))
            let pool = ConnectionPool(config: config, logger: logger, effects: simulation.effects, events: simulation.events)

            lifecycle.register(label: "server", start: .sync(pool.start), shutdown: .sync(pool.shutdown))

            lifecycle.start
            {
                error in

                if let error = error
                {
                    logger.error("failed starting automat-pool ☠️: \(error)")
                }
                else
                {
                    logger.info("automat-pool started successfully 🚀")
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
