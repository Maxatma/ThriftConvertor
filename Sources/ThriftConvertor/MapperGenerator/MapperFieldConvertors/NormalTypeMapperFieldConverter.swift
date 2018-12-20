//
//  NormalTypeMapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class NormalTypeMapperFieldConverter: MapperFieldConverterBase {
    override func mapFromAPIToRealmCode() -> String {
        switch state {
        case .optional:
            switch typeValue {
            case ThriftType.string:
                code = "entity.\(name) = apiEntity.\(name)"
            case ThriftType.bool, ThriftType.i16, ThriftType.i32, ThriftType.i64, ThriftType.double:
                code = "entity.\(name).value = apiEntity.\(name)"
                
            default:
                code = somethingWrongString
            }
        case .normal:
            switch typeValue {
            case ThriftType.string,
                 ThriftType.i16, ThriftType.i32, ThriftType.i64,
                 ThriftType.bool, ThriftType.double :
                code = "entity.\(name) = apiEntity.\(name)"
            default:
                code = somethingWrongString
            }
        }
        
        return code
    }
    
    override func mapFromRealmToAPICodeWithCreation() -> String {
        switch state {
        case .optional:
            switch typeValue {
            case ThriftType.string:
                code = "\(name): entity.\(name)"
            case ThriftType.bool, ThriftType.i16, ThriftType.i32, ThriftType.i64, ThriftType.double:
                code = "\(name): entity.\(name).value"

            default:
                code = somethingWrongString
            }
        case .normal:
            switch typeValue {
            case ThriftType.string,
                 ThriftType.i16, ThriftType.i32, ThriftType.i64,
                 ThriftType.bool, ThriftType.double :
                code = "\(name): entity.\(name)"
            default:
                code = somethingWrongString
            }
        }
        
        return code
    }
    
    override func mapFromRealmToAPICode() -> String {
        switch state {
        case .optional:
            switch typeValue {
            case ThriftType.string:
                code = "apiEntity.\(name) = entity.\(name)"
            case ThriftType.bool, ThriftType.i16, ThriftType.i32, ThriftType.i64, ThriftType.double:
                code = "apiEntity.\(name) = entity.\(name).value"
                
            default:
                code = somethingWrongString
            }
        case .normal:
            switch typeValue {
            case ThriftType.string,
                 ThriftType.i16, ThriftType.i32, ThriftType.i64,
                 ThriftType.bool, ThriftType.double :
                code = "apiEntity.\(name) = entity.\(name)"
            default:
                code = somethingWrongString
            }
        }
        
        return code
    }
}

