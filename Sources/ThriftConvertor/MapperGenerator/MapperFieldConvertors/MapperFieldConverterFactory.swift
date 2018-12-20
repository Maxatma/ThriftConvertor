//
//  MapperFieldConverterFactory.swift
//  ThriftConvertor
//
//  Created by Alexandr on 2/15/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//

import Foundation
import ThriftBase


final class MapperFieldConverterFactory  {
    static func createVMFor(field: ThriftField, converter: Converter) -> MapperFieldConverterBase {
        let type = converter.typeMapper.map(type: field.type)!
        switch type {
        case .map:
            return MapMapperFieldConverter(field: field, converter: converter)
        case .class:
            return ClassMapperFieldConverter(field: field, converter: converter)
        case .collection:
            return CollectionMapperFieldConverter(field: field, converter: converter)
        case .enum:
            return EnumMapperFieldConverter(field: field, converter: converter)
        case .normalType:
            return NormalTypeMapperFieldConverter(field: field, converter: converter)
        }
    }
}

