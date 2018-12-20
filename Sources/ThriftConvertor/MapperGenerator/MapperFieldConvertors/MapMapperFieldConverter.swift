//
//  MapMapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation


final class MapMapperFieldConverter: MapperFieldConverterBase {
    
    //TODO: FIX situation when mapping thrift enums, thrift classes
    //SO : 1) create a nested class from string <key, value>
    //          a) create new class that incapsulate that functionality
    //     2) implement it into MapMapperFieldConverter
    //     3) check it out
    
    
    let types = ["i16": "Int16",
                 "i32": "Int32",
                 "i64": "Int64",
                 "string": "String",
                 "bool": "Bool",
                 "double": "Double",
                 ]
    
    override func mapFromAPIToRealmCode() -> String {
        guard subTypeValue != nil else {
            code = somethingWrongString
            return code
        }
        
        let entityType = converter.prefix + name.capitalized + "NestedMapObject"
        let mapper     = "\(entityType)Mapper"
        
        if optional {
            code = """
            entity.\(name).removeAll()
            if let api\(name) = apiEntity.\(name) {
            let realm\(name): [\(entityType)] = api\(name).map { apiValue  in
            let mapper       = \(mapper).shared
            var returnEntity = \(entityType)()
            returnEntity = mapper.map(apiEntity: apiValue, into: returnEntity)
            return returnEntity
            }
            
            if let realm = try? RealmLoader.shared.loadRealm() {
            realm.add(realm\(name), update:true)
            }
            entity.\(name).append(objectsIn:realm\(name))
            }
            """
        } else {
            code = """
            entity.\(name).removeAll()
            let api\(name) = apiEntity.\(name)
            let realm\(name): [\(entityType)] = api\(name).map { apiValue  in
            let mapper       = \(mapper).shared
            var returnEntity = \(entityType)()
            returnEntity     = mapper.map(apiEntity: apiValue, into: returnEntity)
            return returnEntity
            }
            if let realm = try? RealmLoader.shared.loadRealm() {
            realm.add(realm\(name), update:true)
            }
            
            entity.\(name).append(objectsIn:realm\(name))
            """
        }
        return code
    }
    
    override func mapFromRealmToAPICodeWithCreation() -> String {
        guard subTypeValue != nil else {
            code = somethingWrongString
            return code
        }
        
        let entityType = converter.prefix + name.capitalized + "NestedMapObject"
        let mapper     = "\(entityType)Mapper"
        
        if optional {
            code = "\(name): TMap(Dictionary(uniqueKeysWithValues: Array(entity.\(name).map { \(mapper).shared.map(entity: $0)})))"
        } else {
            code = "\(name): TMap(Dictionary(uniqueKeysWithValues: Array(entity.\(name).map { \(mapper).shared.map(entity: $0)})))"
        }
        
        return code
    }
    
    override func mapFromRealmToAPICode() -> String {
        guard subTypeValue != nil else {
            code = somethingWrongString
            return code
        }
        
        let entityType = converter.prefix + name.capitalized + "NestedMapObject"
        let mapper     = "\(entityType)Mapper"
        
        if optional {
            code = "apiEntity.\(name) = TMap(Dictionary(uniqueKeysWithValues: Array(entity.\(name).map { \(mapper).shared.map(entity: $0)})))"
        } else {
            code = "apiEntity.\(name) = TMap(Dictionary(uniqueKeysWithValues: Array(entity.\(name).map { \(mapper).shared.map(entity: $0)})))"
        }
        
        return code
    }    
}

