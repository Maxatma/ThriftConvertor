//
//  ThriftToRealmConverterTypesMapper.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/4/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class ThriftToRealmConverterTypesMapper {
    
    let thriftClassNames: Set<String>
    let thriftEnumsNames: Set<String>
    
    init(thriftClassNames: Set<String>,
         thriftEnumsNames: Set<String>) {
        self.thriftClassNames = thriftClassNames
        self.thriftEnumsNames = thriftEnumsNames
    }
    
    func mapToConverterString(thriftType: String) -> String {
        var returnString = ""
        switch thriftType {
        case ThriftType.string:
            returnString = "String"
        case ThriftType.bool:
            returnString = "Bool"
        case ThriftType.i16:
            returnString = "Int16"
        case ThriftType.i32:
            returnString = "Int32"
        case ThriftType.i64:
            returnString = "Int64"
        case ThriftType.double:
            returnString = "Double"
        default:
            returnString = thriftType
        }
        return returnString
    }
    
    //TODO: Check if needed ( written but never used )
//    func map(converterType: ThriftToRealmConverterType, state: ThriftToRealmConverterState) -> ThriftToRealmConverterPropertyType {
//
//        switch converterType {
//
//        case .map:
//            return .dynamic
//
//        case .normalType:
//            switch state {
//            case .optional:
//                return .dynamic
//            case .normal:
//                return .let
//            }
//
//        case .`class`:
//            return .dynamic
//
//        case .collection:
//            return .let
//
//        case .`enum`:
//            switch state {
//            case .optional:
//                return .dynamic
//            case .normal:
//                return .let
//            }
//        }
//    }
    
    func map(type: String?) -> ThriftToRealmConverterType? {
        guard let type = type else {
            return nil
        }
        
        if isClass(fieldType: type) {
            return .`class`
        }
        
        if isEnum(fieldType: type) {
            return .`enum`
        }

        if type == ThriftType.map {
            return .map
        }
        
        
        if type == ThriftType.list || type == ThriftType.set {
            return .collection
        }
        
        if isKindOfInt64(type: type) || isKindOfString(type: type) || type == ThriftType.i32 || type == ThriftType.bool {
            return .normalType
        }
        
        return nil
    }
    
    
    private func isClass(fieldType: String) -> Bool {
        return thriftClassNames.contains(fieldType)
    }
    
    private func isEnum(fieldType: String) -> Bool {
        return thriftEnumsNames.contains(fieldType)
    }
    
    private func isKindOfString(type: String) -> Bool {
        return type == ThriftType.string
    }
    
    private func isKindOfInt64(type: String) -> Bool {
        return type == ThriftType.i64
    }
    
    private func isKindOfInt32(type: String) -> Bool {
        return type == ThriftType.i32
    }
}

