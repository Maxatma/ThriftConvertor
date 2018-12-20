//
//  ThriftToRealmConverter.swift
//  ThriftConvertor
//
//  Created by Alexander Zaporozhchenko on 10/4/18.
//  Copyright © 2018 Alexander Zaporozhchenko. All rights reserved.
//

import Foundation
import ThriftFinder
import ThriftBase


let separator = "\n"
let tab       = "    "


final class ThriftToRealmConverter: Converter {
    
    internal func convert(thriftCLass: ThriftClass) -> String {
        
        let imports = """
import RealmSwift

"""
        let name           = prefix + thriftCLass.name.trimmingCharacters(in: .whitespaces)
        let superClassName = "Object"
        let title          = "open class \(name): \(superClassName)"
        
        let hasId          = thriftCLass.fields.contains { $0.name == "id" }
        let primaryKeyFunc = realmClassPrimaryKey(hasId: hasId)
        
        
        let fields = thriftCLass.fields.map { convert(field: $0) }
        let body   = fields.joined(separator: separator + separator)
        
        let classCode = [separator,
                         imports,
                         separator,
                         title + opening,
                         primaryKeyFunc,
                         body,
                         closing,
                         separator]
            .joined(separator: separator)
        
        return classCode
    }
    
    internal func convert(field: ThriftField) -> String {
        
        let comment    = field.comment
        let realmField = convertToRealmField(name: field.name,
                                             type: field.type,
                                             subType: field.subType,
                                             optional: field.optional)
        
        
        let fieldString   = tab + realmField
        let commentString = comment != nil ? tab + comment!.trimmingCharacters(in: .whitespacesAndNewlines) + separator : ""
        let returnString  = commentString + fieldString
        
        return returnString
    }
    
    internal func realmClassPrimaryKey(hasId: Bool) -> String {
        if hasId {
            return """
            override open static func primaryKey() -> String? {
                return "id"
            }
            """
        }
        
        return """
        public dynamic var id = NSUUID().uuidString
        
        override open static func primaryKey() -> String? {
            return "id"
        }
        """
    }
    
    internal func createPropertyString(name: String,
                                       type: ThriftToRealmConverterPropertyType,
                                       public isPublic: Bool) -> String {
        let letPropertyPrefix        = "\(isPublic ? "public ": "" )let "
        let dynamicVarPropertyPrefix = "@objc \(isPublic ? "public ": "" )dynamic var "
        
        switch type {
        case .dynamic:
            return dynamicVarPropertyPrefix + name
        case .`let`:
            return letPropertyPrefix + name
        }
    }
    
    internal func convertToRealmField(name: String,
                                      type: String,
                                      subType: String?,
                                      optional: Bool) -> String {
        
        let isPublic     = true
        var returnString = ""
        
        //TODO: add this for renaming rules
        //        var name = name
        //        if name == "hash" {
        //            name = "tthash"
        //        }
        
        
        let converterType: ThriftToRealmConverterType   = typeMapper.map(type: type)!
        let converterState: ThriftToRealmConverterState = optional ? .optional : .normal
        
        let somethingWrongString = "// Can't convert \(name) of type \(type) with subType: \(String(describing: subType))"
        
        switch converterType {
            
        case .map:
            if subType != nil {
                let typeName         = prefix + name.capitalized + "NestedMapObject"
                let propertyLeftSide = createPropertyString(name: name, type: .let, public: isPublic)
                returnString         = propertyLeftSide + "= List<\(typeName)>()"
                print("created \(typeName) for \(name) map with subtype \(subType!)")
                return returnString
            }
            
        case .class:
            let typeName = prefix + type
            let propertyLeftSide = createPropertyString(name: name, type: .dynamic, public: isPublic)
            returnString =  propertyLeftSide + ": \(typeName)?"
            return returnString
            
        case .collection:
            guard let sub = subType else {
                return somethingWrongString
            }
            
            let subConverterType   = typeMapper.map(type: sub)!
            let subConverterString = typeMapper.mapToConverterString(thriftType: sub)
            
            let propertyLeftSide = createPropertyString(name: name, type: .let, public: isPublic)
            
            switch subConverterType {
            case .class:
                let subtypeName = prefix + sub
                returnString = propertyLeftSide + " = List<\(subtypeName)>()"
            case .normalType:
                returnString = propertyLeftSide + " = List<\(subConverterString)>()"
            case .enum:
                returnString = propertyLeftSide + " = List<Int32>()"
            default:
                print(somethingWrongString)
                return somethingWrongString
            }
            
            return returnString
            
        case .enum:
            switch converterState {
                
            case .optional:
                let propertyLeftSide = createPropertyString(name: name, type: .let, public: isPublic)
                returnString = propertyLeftSide + " = RealmOptional<Int32>()"
                
            case .normal:
                let propertyLeftSide = createPropertyString(name: name, type: .dynamic, public: isPublic)
                returnString = propertyLeftSide + ": Int32 = 0"
            }
            
            return returnString
            
        case .normalType:
            switch converterState {
                
            case .optional:
                
                let typeString = typeMapper.mapToConverterString(thriftType: type)
                
                switch type {
               
                case ThriftType.string:
                    let propertyLeftSide = createPropertyString(name: name, type: .dynamic, public: isPublic)
                    returnString         = propertyLeftSide + ": \(typeString)?"
               
                case ThriftType.bool, ThriftType.i16, ThriftType.i32, ThriftType.i64, ThriftType.double:
                    let propertyLeftSide = createPropertyString(name: name, type: .let, public: isPublic)
                    returnString         = propertyLeftSide + " = RealmOptional<\(typeString)>()"
                    
                default:
                    print(somethingWrongString)
                    return somethingWrongString
                }
                
                return returnString
                
            case .normal:
                let propertyLeftSide = createPropertyString(name: name, type: .dynamic, public: isPublic)

                switch type {
                case ThriftType.string:
                    returnString =  propertyLeftSide + " = \"\" "
                case ThriftType.bool:
                    returnString =  propertyLeftSide + " = false"
                case ThriftType.i16:
                    returnString =  propertyLeftSide + ": Int16 = 0"
                case ThriftType.i32:
                    returnString =  propertyLeftSide + ": Int32 = 0"
                case ThriftType.i64:
                    returnString =  propertyLeftSide + ": Int64 = 0"
                case ThriftType.double:
                    returnString =  propertyLeftSide + ": Double = 0.0"
                    
                default:
                    print(somethingWrongString)
                    return somethingWrongString
                }
                
                return returnString
            }
        }
        print(somethingWrongString)
        return somethingWrongString
    }
}

