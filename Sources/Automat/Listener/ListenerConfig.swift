//
//  ListenerConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/16/22.
//

import Foundation

public struct ListenerConfig: Codable
{
    let host: String
    let port: Int

    public init(host: String, port: Int)
    {
        self.host = host
        self.port = port
    }
}
