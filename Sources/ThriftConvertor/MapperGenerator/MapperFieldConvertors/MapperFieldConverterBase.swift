//
//  MapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


class MapperFieldConverterBase  {
    let field: ThriftField
    let converter: Converter
    
    let name: String
    let type: ThriftToRealmConverterType
    let typeValue: String
    let subType: ThriftToRealmConverterType?
    let subTypeValue: String?
    let optional: Bool
    let state: ThriftToRealmConverterState
    let somethingWrongString: String
    var code = ""
    
    required init(field: ThriftField, converter: Converter) {
        
        self.converter   = converter
        self.field       = field
        
        name                 = field.name
        typeValue            = field.type
        type                 = converter.typeMapper.map(type: typeValue)!
        self.subTypeValue    = field.subType
        subType              = converter.typeMapper.map(type: subTypeValue)
        optional             = field.optional
        state                = optional ? .optional : .normal
        somethingWrongString = "// Can't convert \(name) of type \(field.type) with subType: \(String(describing: field.subType))"
    }
    
    func mapFromAPIToRealmCode() -> String {
        fatalError("This method must be overriden by the subclass")
    }
    
    func mapFromRealmToAPICodeWithCreation() -> String {
        fatalError("This method must be overriden by the subclass")
    }
    
    func mapFromRealmToAPICode() -> String {
        fatalError("This method must be overriden by the subclass")
    }
    
}

