//
//  CodeConvertorTests.swift
//  ThriftConvertorTests
//
//  Created by Alexander Zaporozhchenko on 10/15/18.
//  Copyright © 2018 Alexander Zaporozhchenko. All rights reserved.
//

import XCTest
@testable import ThriftConvertor


class ThriftConvertorTests: XCTestCase {
    
    func getTestText() -> String {
        return """
        struct TestAPIObject {
        1: optional string id;
        
        2: optional i64 optionalIntSixtyFour;
        3: i64 nonOptionalIntSixtyFour;
        
        4: optional i32 optionalIntThirtyTwo;
        5: i32 nonOptionalThirtyTwo;
        
        6: optional bool optionalBool;
        7: bool nonOptionalBool;
        
        8: optional string optionalString;
        9: string nonOptionalString;
        
        
        10: optional TestAPIObject nestedType;
        11: optional list<TestAPIObject> nestedTypesList;
        }
"""
    }
    
    func testExample() {
        let content       = getTestText()
        let converter     = CodeConverter.init(prefix: "TT", exceptionNames: [])
        let classes       = converter.createRealmClasses(thriftText: content)
        let mapperClasses = converter.createMapperClasses(thriftText: content)
        
        print(classes)
        print(mapperClasses)
    }
}

