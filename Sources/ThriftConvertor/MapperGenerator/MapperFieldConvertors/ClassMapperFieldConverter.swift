//
//  ClassMapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation


final class ClassMapperFieldConverter: MapperFieldConverterBase {
    override func mapFromAPIToRealmCode() -> String {
        
        guard let nestedClass = converter.thriftClasses.first(where: { $0.name == typeValue }) else {
            code = somethingWrongString
            return code
        }
        
        let containsID            = nestedClass.fields.contains(where: { $0.name == "id" } )
        let primaryKey            = containsID ? "api\(name).id!" : "nil"
        let mapper                = "\(converter.prefix)\(typeValue)Mapper"
        let idCheck               = containsID ? ", api\(name).id != nil " : " "
        
        if optional {
            code = """
            if let api\(name) = apiEntity.\(name) \(idCheck){
            let mapper       = \(mapper).shared
            let returnEntity = mapper.getOrCreate(primaryKey: \(primaryKey))
            entity.\(name)   = mapper.map(apiEntity: api\(name), into: returnEntity)
            } else {
            entity.\(name) = nil
            }
            """
        } else {
            code = """
            let api\(name) = apiEntity.\(name)
            let mapper       = \(mapper).shared
            let returnEntity = mapper.getOrCreate(primaryKey: \(primaryKey))
            entity.\(name)   = mapper.map(apiEntity: api\(name), into: returnEntity)
            """
        }
        return code
    }
    
    override func mapFromRealmToAPICodeWithCreation() -> String {
        let mapper = "\(converter.prefix)\(typeValue)Mapper"
        
        if optional {
            code = "\(name): \(mapper).shared.map(entity: entity.\(name))"
        } else {
            code = "\(name): \(mapper).shared.map(entity: entity.\(name))!"
        }
        return code
    }
    
    override func mapFromRealmToAPICode() -> String {
        let mapper = "\(converter.prefix)\(typeValue)Mapper"
        
        if optional {
            code = "apiEntity.\(name) = \(mapper).shared.map(entity: entity.\(name))"
        } else {
            code = "apiEntity.\(name) = \(mapper).shared.map(entity: entity.\(name))!"
        }
        return code
    }
    
}

