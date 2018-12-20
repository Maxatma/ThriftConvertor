//
//  Converter.swift
//  ThriftConvertor
//
//  Created by Alexander Zaporozhchenko on 10/4/18.
//  Copyright © 2018 Alexander Zaporozhchenko. All rights reserved.
//

import Foundation
import ThriftFinder
import ThriftBase


class Converter {
    let thriftClassNames: Set<String>
    let thriftEnumsNames: Set<String>
    let thriftClasses: Array<ThriftClass>
    let prefix: String

    let opening = " {"
    let closing = "}"
    var typeMapper: ThriftToRealmConverterTypesMapper!
    
    
    init(thriftClassNames: Set<String>,
         thriftEnumsNames: Set<String>,
         thriftClasses: Array<ThriftClass>,
         prefix: String) {
        
        self.thriftClassNames = thriftClassNames
        self.thriftEnumsNames = thriftEnumsNames
        self.thriftClasses    = thriftClasses
        self.prefix           = prefix
        
        typeMapper = ThriftToRealmConverterTypesMapper(thriftClassNames: thriftClassNames, thriftEnumsNames: thriftEnumsNames)
    }
}

