//
//  EnumMapperFieldConverter.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation


//TODO: separate names Entity and APIEntity to configurable things


final class EnumMapperFieldConverter: MapperFieldConverterBase {
    override func mapFromAPIToRealmCode() -> String {
        switch state {
        case .optional:
            code = "entity.\(name).value = apiEntity.\(name)?.rawValue"
        case .normal:
            code = "entity.\(name) = apiEntity.\(name).rawValue"
        }
        
        return code
    }
    
    override func mapFromRealmToAPICodeWithCreation() -> String {
        switch state {
        case .optional:
            code = "\(name): entity.\(name).value == nil ? nil : \(typeValue)(rawValue: entity.\(name).value!)"
        case .normal:
            code = "\(name): \(typeValue)(rawValue: entity.\(name))!"
        }
        
        return code
    }
    
    override func mapFromRealmToAPICode() -> String {
        switch state {
        case .optional:
            code = "apiEntity.\(name) = entity.\(name).value == nil ? nil : \(typeValue)(rawValue: entity.\(name).value!)"
        case .normal:
            code = "apiEntity.\(name) = \(typeValue)(rawValue: entity.\(name))!"
        }
        
        return code
    }

}

