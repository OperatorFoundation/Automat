//
//  ControllerEffect.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/18/22.
//

import Foundation

import Spacetime

public enum ControllerEffect: Codable
{
    case ListenRequest(ListenRequest)
    case ConnectRequest(ConnectRequest)
}

public enum ControllerEvent: Codable
{
    case ListenResponse(ListenResponse)
    case ConnectResponse(ConnectResponse)
    case Failure(Failure)
}
