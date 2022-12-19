//
//  ControllerState.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/19/22.
//

import Foundation

import Transmission

public class ControllerState
{
    public let listeners: ServerController = ServerController()
    public let connectionPools: ServerController = ServerController()

    public init()
    {
    }
}

public class ServerController
{
    var pool: [ServerInfo] = []

    public func add(info: ServerInfo)
    {
        self.pool.append(info)
    }

    public func remove(id: UUID)
    {
        self.pool = self.pool.filter {$0.id != id}
    }

    public func find() throws -> ServerInfo
    {
        self.pool.sort {$0.capacity > $1.capacity}

        let maybeResult = self.pool.first {$0.capacity > 0}
        guard let result = maybeResult else
        {
            throw ControllerStateError.noServersWithCapacity
        }

        return result
    }
}

public struct ServerInfo
{
    let id: UUID
    let connection: Transmission.Connection
    let capacity: Int

    public init(id: UUID, connection: Transmission.Connection, capacity: Int)
    {
        self.id = id
        self.connection = connection
        self.capacity = capacity
    }
}

public enum ControllerStateError: Error
{
    case noServersWithCapacity
}
