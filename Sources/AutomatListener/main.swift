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
        commandName: "automat-listener",
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

            let config = ListenerConfig(host: ip, port: port)
            let encoder = JSONEncoder()
            let configData = try encoder.encode(config)
            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-config.json")
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
            let logger = Logger(subsystem: "org.OperatorFoundation.AutomatListener", category: "Persona")
            #else
            let logger = Logger(label: "org.OperatorFoundation.AutomatListener")
            #endif

            let configURL = URL(fileURLWithPath: File.currentDirectory()).appendingPathComponent("automat-config.json")
            let configData = try Data(contentsOf: configURL)
            let decoder = JSONDecoder()
            let config = try decoder.decode(ListenerConfig.self, from: configData)
            print("Read config from \(configURL.path)")

            let lifecycle = ServiceLifecycle()

            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            lifecycle.registerShutdown(label: "eventLoopGroup", .sync(eventLoopGroup.syncShutdownGracefully))

            let simulation = Simulation(capabilities: Capabilities(.display, .networkListen))
            let listener = Listener(config: config, logger: logger, effects: simulation.effects, events: simulation.events)

            lifecycle.register(label: "server", start: .sync(listener.start), shutdown: .sync(listener.shutdown))

            lifecycle.start
            {
                error in

                if let error = error
                {
                    logger.error("failed starting automat-listener ☠️: \(error)")
                }
                else
                {
                    logger.info("automat-listener started successfully 🚀")
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
