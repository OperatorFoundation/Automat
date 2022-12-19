//
//  ConnectionPool.swift
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
import Universe

public class ConnectionPool: Universe
{
    public init(config: ConnectionPoolConfig, logger: Logger, effects: BlockingQueue<Effect>, events: BlockingQueue<Event>)
    {
        super.init(effects: effects, events: events, logger: logger)
    }

    public func start()
    {
    }

    public func shutdown()
    {
    }
}
