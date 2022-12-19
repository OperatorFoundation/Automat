//
//  Allocator.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/19/22.
//

import Foundation

public class Allocator
{
    public init()
    {
    }

    public func newListener() throws -> ServerInfo
    {
        throw AllocatorError.unimplemented
    }

    public func newConnectionPool() throws -> ServerInfo
    {
        throw AllocatorError.unimplemented
    }

    public func newLogicLayer() throws -> ServerInfo
    {
        throw AllocatorError.unimplemented
    }
}

public enum AllocatorError: Error
{
    case unimplemented
}
