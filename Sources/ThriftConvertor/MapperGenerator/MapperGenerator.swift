//
//  MapperGenerator.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/5/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class MapperGenerator: Converter  {
    
    func generateMapperCode(classes: [ThriftClass]) -> [String] {
        let code = classes.map { createCodeForClass(thriftClass: $0) }
        return code
    }
    
    func createCodeForClass(thriftClass: ThriftClass) -> String {
        
        let imports = """
import RealmSwift
import Thrift
"""
        let className   = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces) + "Mapper"
        let inheritance = ": MapperProtocol"
        let title       = "open class \(className)\(inheritance)"
        let shared      = tab + "public static var shared = \(className)()"
        
        let functionMapFromAPIToRealm             = createFunctionMapFromAPIToRealm(thriftClass: thriftClass)
        let functionMapFromRealmToAPI             = createFunctionMapFromRealmToAPI(thriftClass: thriftClass)
        let functionMapFromRealmToAPIWithCreation = createFunctionMapFromRealmToAPIWithCreation(thriftClass: thriftClass)
        let getOrCreateCode                       = addGetOrCreateCode(thriftClass: thriftClass)

        let body = [shared,
                    createRequiredInit(),
                    functionMapFromAPIToRealm,
                    functionMapFromRealmToAPI,
                    functionMapFromRealmToAPIWithCreation,
                    getOrCreateCode
            ]
            .joined(separator: separator)
        
        let classCode = [
            imports,
            separator,
            title + opening,
            body,
            closing,
            separator
            ]
            .joined(separator: separator)
        
        return classCode
    }
    
    func createRequiredInit() -> String {
        return """
        
    public required init() { }
        
"""
    }
    
    func createFunctionMapFromAPIToRealm(thriftClass: ThriftClass) -> String {
        let apiClassName    = thriftClass.name.trimmingCharacters(in: .whitespaces)
        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        
        let title        = "public func map(apiEntity: \(apiClassName), into entity: \(entityClassName)) -> \(entityClassName) {"
        let returnEntity = "    " + "return entity"
        let hasID        = thriftClass.fields.contains { $0.name == "id" }
        
        let primary = hasID ? """
            if entity.value(forKey: "id") == nil {
                entity.setValue(apiEntity.id, forKey: "id")
            }
        """
        : ""
        
        let body = thriftClass.fields
            .filter { $0.name != "id" }
            .map { mapFromAPIToRealm(field:$0) }
            .map { "\n\n    " + $0.replacingOccurrences(of: "\n", with: "\n    ")}
            .joined()
        
        let code = [title,
                    primary,
                    body,
                    returnEntity,
                    closing
            ]
            .joined(separator: separator)
        
        return code
    }
    
    func createFunctionMapFromRealmToAPI(thriftClass: ThriftClass) -> String {
        let apiClassName    = thriftClass.name.trimmingCharacters(in: .whitespaces)
        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        
        let title        = "public func map(entity: \(entityClassName), into apiEntity: \(apiClassName)) -> \(apiClassName) {"
        let returnEntity = "    " + "return apiEntity"

        let body  = thriftClass.fields
            .map { mapFromRealmToAPI(field:$0) }
            .joined(separator: separator + "    ")
        
        let code = [title,
                    body,
                    returnEntity,
                    closing
            ]
            .joined(separator: separator)
        
        return code
    }

    func createFunctionMapFromRealmToAPIWithCreation(thriftClass: ThriftClass) -> String {
        let apiClassName    = thriftClass.name.trimmingCharacters(in: .whitespaces)
        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        let title           = "public func map(entity: \(entityClassName)?) -> \(apiClassName)?" + opening
        let guardEntity     = "    " + "guard let entity = entity else { return nil }"
        let returnEntity    = "    " + "return \(apiClassName)("
        let entityClosing   = "    " + ")"
        
        let body  = thriftClass.fields
            .map { mapFromRealmToAPIWithCreation(field:$0) }
            .joined(separator: "," + separator + "    ")
        
        let code = [title,
                    guardEntity,
                    returnEntity,
                    body,
                    entityClosing,
                    closing
            ]
            .joined(separator: separator)
        
        return code
    }
    
    func addGetOrCreateCode(thriftClass: ThriftClass) -> String {
        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        let code = """
public func getOrCreate(primaryKey: String? = nil) -> \(entityClassName) {
        
        let realm = try! RealmLoader.shared.loadRealm()
        
        if primaryKey == nil {
            return \(entityClassName)()
        }
        
        let savedObject  = realm.object(ofType: \(entityClassName).self, forPrimaryKey: primaryKey)
        let returnEntity = savedObject ?? \(entityClassName)()

        return returnEntity
}
"""
        return code
    }
    
    func mapFromRealmToAPIWithCreation(field: ThriftField) -> String {
        let fieldConverter = MapperFieldConverterFactory.createVMFor(field: field, converter: self)
        return fieldConverter.mapFromRealmToAPICodeWithCreation()
    }
    
    func mapFromRealmToAPI(field: ThriftField) -> String {
        let fieldConverter = MapperFieldConverterFactory.createVMFor(field: field, converter: self)
        return fieldConverter.mapFromRealmToAPICode()
    }
    
    func mapFromAPIToRealm(field: ThriftField) -> String {
        let fieldConverter = MapperFieldConverterFactory.createVMFor(field: field, converter: self)
        return fieldConverter.mapFromAPIToRealmCode()
    }
}

