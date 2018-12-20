//
//  TMapMapperGenerator.swift
//  ThriftConvertor
//
//  Created by Alexander Zaporozhchenko on 7/9/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class TMapMapperGenerator: Converter  {
    
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
        let inheritance = ": TMapMapperProtocol"
        let title       = "open class \(className)\(inheritance)"
        
        let body = createMapperBody(thriftClass: thriftClass, className: className)
        
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
    
    private func createMapperBody(thriftClass: ThriftClass, className: String) -> String {
        
        let shared                                = tab + "public static var shared = \(className)()"
        let functionMapFromAPIToRealm             = createFunctionMapFromAPIToRealm(thriftClass: thriftClass)
        let functionMapFromRealmToAPIWithCreation = createFunctionMapFromRealmToAPIWithCreation(thriftClass: thriftClass)
        
        let body = [shared,
                    createRequiredInit(),
                    functionMapFromAPIToRealm,
                    functionMapFromRealmToAPIWithCreation,
                    ]
            .joined(separator: separator)
        
        return body
    }
    
    func createRequiredInit() -> String {
        return """
        
        public required init() { }
        
        """
    }
    
    func createFunctionMapFromAPIToRealm(thriftClass: ThriftClass) -> String {
        
        let keyType    = typeMapper.mapToConverterString(thriftType: thriftClass.fields.first!.type)
        let valueType  = typeMapper.mapToConverterString(thriftType: thriftClass.fields[1].type)

        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        let title           = "public func map(apiEntity:(key: \(keyType), value: \(valueType)), into entity: \(entityClassName)) -> \(entityClassName) {"
        let returnEntity    = tab + "return entity"
        
        let body = thriftClass.fields
            .map { mapFromAPIToRealm(field:$0) }
            .map { "\n\n    " + $0.replacingOccurrences(of: "\n", with: "\n    ")}
            .joined()
        
        let code = [title,
                    body,
                    returnEntity,
                    closing
            ]
            .joined(separator: separator)
        
        return code
    }
    
    func createFunctionMapFromRealmToAPIWithCreation(thriftClass: ThriftClass) -> String {
        let keyType    = typeMapper.mapToConverterString(thriftType: thriftClass.fields.first!.type)
        let valueType  = typeMapper.mapToConverterString(thriftType: thriftClass.fields[1].type)

        let entityClassName = prefix + thriftClass.name.trimmingCharacters(in: .whitespaces)
        let title           = "public func map(entity: \(entityClassName)) -> (key: \(keyType), value: \(valueType))" + opening
        let returnEntity    = tab + "return ( "
        let entityClosing   = tab + ")"
        
        let body  = thriftClass.fields
            .map { mapFromRealmToAPIWithCreation(field:$0) }
            .joined(separator: "," + separator + tab)
        
        let code = [title,
                    returnEntity,
                    body,
                    entityClosing,
                    closing
            ]
            .joined(separator: separator)
        
        return code
    }
    
    func mapFromAPIToRealm(field: ThriftField) -> String {
        let fieldConverter = MapperFieldConverterFactory.createVMFor(field: field, converter: self)
        return fieldConverter.mapFromAPIToRealmCode()
    }
    
    func mapFromRealmToAPIWithCreation(field: ThriftField) -> String {
        let fieldConverter = MapperFieldConverterFactory.createVMFor(field: field, converter: self)
        return fieldConverter.mapFromRealmToAPICodeWithCreation()
    }
}

