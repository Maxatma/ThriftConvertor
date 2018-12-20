//
//  ThriftToRealmConverterTests.swift
//  ThriftConvertorTests
//
//  Created by Alexander Zaporozhchenko on 11/13/18.
//  Copyright © 2018 Alexander Zaporozhchenko. All rights reserved.
//

import XCTest
@testable import ThriftConvertor
@testable import ThriftFinder
@testable import ThriftBase


class ThriftToRealmConverterFieldCovertTests: XCTestCase {
    
    let thriftText: String = """
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
    
    
    var converter: ThriftToRealmConverter!
    
    override func setUp() {
        let finder             = Finder()
        let thriftClassesNames = finder.findAllClassNamesIn(text: thriftText)
        let thriftEnumsNames   = finder.findAllEnumsNamesIn(text: thriftText)
        let classes            = finder.createTrfitClassesFrom(text: thriftText)
        
        converter = ThriftToRealmConverter(thriftClassNames: thriftClassesNames,
                                               thriftEnumsNames: thriftEnumsNames,
                                               thriftClasses: classes,
                                               prefix: "XX")

        print("setup called")
        super.setUp()
    }
    
    func testInt32Optional() {
        
        let thriftField = ThriftField(comment: "//testComment",
                                      number: 2,
                                      optional: true,
                                      type: "i32",
                                      subType: nil,
                                      name: "optionalIntThirtyTwo")
        
        let property = converter.convert(field: thriftField)
        let expectedString = "    //testComment\n    public let optionalIntThirtyTwo = RealmOptional<Int32>()"
        XCTAssertEqual(expectedString, property)
    }
    
    func testInt32() {
        
        let thriftField = ThriftField(comment: nil,
                                      number: 3,
                                      optional: false,
                                      type: "i32",
                                      subType: nil,
                                      name: "nonOptionalThirtyTwo")
        
        let property = converter.convert(field: thriftField)
        let expectedString = "    @objc public dynamic var nonOptionalThirtyTwo: Int32 = 0"
        XCTAssertEqual(expectedString, property)
    }
    
    
    func testInt64Optional() {
        
        let thriftField = ThriftField(comment: " ",
                                      number: 2,
                                      optional: true,
                                      type: "i64",
                                      subType: nil,
                                      name: "optionalIntSixtyFour")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    \n    public let optionalIntSixtyFour = RealmOptional<Int64>()"
        XCTAssertEqual(expectedString, property)
    }
    
    func testInt64() {
        
        let thriftField = ThriftField(comment: nil,
                                      number: 3,
                                      optional: false,
                                      type: "i64",
                                      subType: nil,
                                      name: "nonOptionalIntSixtyFour")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    @objc public dynamic var nonOptionalIntSixtyFour: Int64 = 0"
        XCTAssertEqual(expectedString, property)
    }
    
    func testBoolOptional() {
        
        let thriftField = ThriftField(comment: " ",
                                      number: 2,
                                      optional: true,
                                      type: "bool",
                                      subType: nil,
                                      name: "optionalBool")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    \n    public let optionalBool = RealmOptional<Bool>()"
        XCTAssertEqual(expectedString, property)
    }
    
    func testBool() {
        
        let thriftField = ThriftField(comment: nil,
                                      number: 3,
                                      optional: false,
                                      type: "bool",
                                      subType: nil,
                                      name: "nonOptionalBool")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    @objc public dynamic var nonOptionalBool = false"
        XCTAssertEqual(expectedString, property)
    }
    
    func testStringOptional() {
        
        let thriftField = ThriftField(comment: " ",
                                      number: 2,
                                      optional: true,
                                      type: "string",
                                      subType: nil,
                                      name: "optionalString")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    \n    @objc public dynamic var optionalString: String?"
        XCTAssertEqual(expectedString, property)
    }
    
    func testString() {
        
        let thriftField = ThriftField(comment: nil,
                                      number: 3,
                                      optional: false,
                                      type: "string",
                                      subType: nil,
                                      name: "nonOptionalString")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    @objc public dynamic var nonOptionalString = \"\" "
        XCTAssertEqual(expectedString, property)
    }
    
    func testClass() {
        
        let thriftField = ThriftField(comment: " ",
                                      number: 21,
                                      optional: true,
                                      type: "TestAPIObject",
                                      subType: nil,
                                      name: "nestedType")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    \n    @objc public dynamic var nestedType: XXTestAPIObject?"
        XCTAssertEqual(expectedString, property)
    }
    
    func testList() {
        
        let thriftField = ThriftField(comment: nil,
                                      number: 45,
                                      optional: false,
                                      type: "list",
                                      subType: "TestAPIObject",
                                      name: "nestedType")
        
        let property       = converter.convert(field: thriftField)
        let expectedString = "    public let nestedType = List<XXTestAPIObject>()"
        XCTAssertEqual(expectedString, property)
    }

}

