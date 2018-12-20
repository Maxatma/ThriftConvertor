//
//  CollectionMapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class CollectionMapperFieldConverter: MapperFieldConverterBase {
    override func mapFromAPIToRealmCode() -> String {
        guard let sub = subType, let subValue = subTypeValue else {
            code = somethingWrongString
            return code
        }
        
        switch sub {
        case .class:
            guard let nestedClass = converter.thriftClasses.first(where: { $0.name == subValue }) else {
                code = somethingWrongString
                return code
            }
            let valueTypeHasID = nestedClass.fields.contains(where: { $0.name == "id" } )
            let primaryKey     = valueTypeHasID  ? "apiValue.id!" : "nil"
            let entityType     = "\(converter.prefix)\(subTypeValue!)"
            let mapper         = "\(entityType)Mapper"
            if optional {
                code = """
                entity.\(name).removeAll()
                if let api\(name) = apiEntity.\(name) {
                let realm\(name): [\(entityType)] = api\(name).map { apiValue  in
                    let mapper       = \(mapper).shared
                    var returnEntity = mapper.getOrCreate(primaryKey: \(primaryKey))
                        returnEntity = mapper.map(apiEntity: apiValue, into: returnEntity)
                        return returnEntity
                    }
                
                    let realm = try! RealmLoader.shared.loadRealm()
                    realm.add(realm\(name), update:true)
                    entity.\(name).append(objectsIn:realm\(name))
                }
                """
            } else {
                code = """
                entity.\(name).removeAll()
                let api\(name) = apiEntity.\(name)
                let realm\(name): [\(entityType)] = api\(name).map { apiValue  in
                    let mapper       = \(mapper).shared
                    var returnEntity = mapper.getOrCreate(primaryKey: \(primaryKey))
                    returnEntity     = mapper.map(apiEntity: apiValue, into: returnEntity)
                    return returnEntity
                }
                let realm = try! RealmLoader.shared.loadRealm()
                realm.add(realm\(name), update:true)
                entity.\(name).append(objectsIn:realm\(name))
                """
            }
        case .normalType:
            code = """
            entity.\(name).removeAll()
            if let api\(name) = apiEntity.\(name) {
                entity.\(name).append(objectsIn: api\(name))
            }
            """
        case .enum:
            if optional {
                code = """
                entity.\(name).removeAll()
                if let api\(name) = apiEntity.\(name) {
                    entity.\(name).append(objectsIn: api\(name).map { $0.rawValue })
                }
                """
            } else {
                code = """
                entity.\(name).removeAll()
                let api\(name) = apiEntity.\(name)
                entity.\(name).append(objectsIn: api\(name).map { $0.rawValue })
                """

            }
        default:
            code = somethingWrongString
        }
        
        return code
    }
    
    override func mapFromRealmToAPICodeWithCreation() -> String {
        guard let sub = subType else {
            code = somethingWrongString
            return code
        }
        
        var collectionType: String
        switch typeValue {
        case ThriftType.set:
            collectionType = "TSet"
        case ThriftType.list:
            collectionType = "TList"
            
        default:
            code = somethingWrongString
            return code
        }
        switch sub {
        case .class:
            let entityType = "\(converter.prefix)\(subTypeValue!)"
            let mapper     = "\(entityType)Mapper"
            code           = "\(name): \(collectionType)(Array(entity.\(name).compactMap { \(mapper).shared.map(entity: $0) }))"
        case .normalType:
            code = "\(name): \(collectionType)(entity.\(name))"
        case .enum:
            code = "\(name): \(collectionType)(Array(entity.\(name).compactMap { \(subTypeValue!)(rawValue:$0) }))"
        default:
            code = somethingWrongString
        }
        
        return code
    }
    
    override func mapFromRealmToAPICode() -> String {
        guard let sub = subType else {
            code = somethingWrongString
            return code
        }
        
        var collectionType: String
        switch typeValue {
        case ThriftType.set:
            collectionType = "TSet"
        case ThriftType.list:
            collectionType = "TList"
            
        default:
            code = somethingWrongString
            return code
        }
        
        switch sub {
        case .class:
            let entityType = "\(converter.prefix)\(subTypeValue!)"
            let mapper = "\(entityType)Mapper"
            code = "apiEntity.\(name) = \(collectionType)(Array(entity.\(name).compactMap { \(mapper).shared.map(entity: $0) }))"
            
        case .normalType:
            code = "apiEntity.\(name) = \(collectionType)(entity.\(name))"
        case .enum:
            code = "apiEntity.\(name) = \(collectionType)(Array(entity.\(name).compactMap { \(subTypeValue!)(rawValue:$0) }))"
        default:
            code = somethingWrongString
        }
        
        return code
    }
}

