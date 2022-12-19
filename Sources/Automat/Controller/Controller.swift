//
//  Controller.swift
//
//
//  Created by Dr. Brandon Wiley on 12/16/22.
//

import Foundation
#if os(macOS) || os(iOS)
import os.log
#else
import Logging
#endif

import Chord
import Simulation
import Spacetime
import Transmission
import Universe

public class Controller: Universe
{
    static let prefixSize = 64

    let config: ListenerConfig
    var listener: Transmission.Listener! = nil
    var running: Bool = true

    let state: ControllerState = ControllerState()

    public init(config: ListenerConfig, logger: Logger, effects: BlockingQueue<Effect>, events: BlockingQueue<Event>) throws
    {
        self.config = config

        super.init(effects: effects, events: events, logger: logger)

        self.listener = try super.listen(config.host, config.port)
    }

    public func start() throws
    {
        Task
        {
            while self.running
            {
                do
                {
                    try self.accept()
                }
                catch
                {
                    print(error)
                    self.running = false
                    return
                }
            }
        }
    }

    public func shutdown() throws
    {
        self.running = false
    }

    func accept() throws
    {
        let connection = try self.listener.accept()

        Task
        {
            self.handleConnection(connection)
        }
    }

    func handleConnection(_ connection: Transmission.Connection)
    {
        while self.running
        {
            guard let data = connection.readWithLengthPrefix(prefixSizeInBits: Self.prefixSize) else
            {
                connection.close()
                return
            }

            let decoder = JSONDecoder()

            do
            {
                let effect = try decoder.decode(ControllerEffect.self, from: data)
                try self.handleEffect(effect)
            }
            catch
            {
                print(error)
                return
            }
        }
    }

    func handleEffect(_ effect: ControllerEffect) throws
    {
        switch effect
        {
            case .ConnectRequest(let request):
                self.handleConnect(request)

            case .ListenRequest(let request):
                self.handleListen(request)
        }
    }

    func handleConnect(_ request: ConnectRequest)
    {

    }

    func handleListen(_ request: ListenRequest)
    {

    }
}

public enum AutomatControllerError: Error
{
    case listenerFailed
}
