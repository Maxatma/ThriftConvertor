//
//  CodeGenerator.swift
//  ThriftConvertor
//
//  Created by Alexander Zaporozhchenko on 10/4/18.
//  Copyright © 2018 Alexander Zaporozhchenko. All rights reserved.
//

import Foundation
import ThriftFinder


public struct ContentFile {
    public let name: String
    public let content: String
}


open class CodeConverter {
    
    private var filesPrefix: String!
    private var exceptions: [String]!
    
    public init(prefix: String, exceptionNames: [String]) {
        self.filesPrefix = prefix
        self.exceptions  = exceptionNames
    }
    
    //MARK: -
    public func createRealmClasses(thriftText: String) -> [ContentFile] {
        
        let finder             = Finder()
        let thriftClassesNames = finder.findAllClassNamesIn(text: thriftText)
        let thriftEnumsNames   = finder.findAllEnumsNamesIn(text: thriftText)
        let classes            = finder.createTrfitClassesFrom(text: thriftText)
        let converter          = ThriftToRealmConverter(thriftClassNames: thriftClassesNames,
                                                        thriftEnumsNames: thriftEnumsNames,
                                                        thriftClasses: classes,
                                                        prefix: filesPrefix)
        
        return classes
            .filter { !exceptions.contains($0.name) }
            .map { triftClass -> ContentFile in
                let content  = converter.convert(thriftCLass: triftClass)
                let fileName = filesPrefix + triftClass.name.trimmingCharacters(in: .whitespaces) + ".swift"
                return ContentFile(name: fileName, content: content)
        }
    }
    
    public func createMapperClasses(thriftText: String) -> [ContentFile] {
        
        let finder             = Finder()
        let thriftClassesNames = finder.findAllClassNamesIn(text: thriftText)
        let thriftEnumsNames   = finder.findAllEnumsNamesIn(text: thriftText)
        let classes            = finder
            .createTrfitClassesFrom(text: thriftText, shouldSearchNestedClasses: false)
            .filter { !exceptions.contains($0.name) }
        
        let converter = MapperGenerator(thriftClassNames: thriftClassesNames,
                                        thriftEnumsNames: thriftEnumsNames,
                                        thriftClasses: classes,
                                        prefix: filesPrefix)
        
        let normalClasses = classes
            .filter { !exceptions.contains($0.name) }
            .map { triftClass -> ContentFile in
                let content  = converter.createCodeForClass(thriftClass: triftClass)
                let fileName = filesPrefix + triftClass.name.trimmingCharacters(in: .whitespaces) + "Mapper.swift"
                return ContentFile(name: fileName, content: content)
        }
        
        let nestedClasses = finder.findNestedClasses(thriftClasses: classes)
        
        let tmapConverter = TMapMapperGenerator(thriftClassNames: thriftClassesNames,
                                                thriftEnumsNames: thriftEnumsNames,
                                                thriftClasses: classes,
                                                prefix: filesPrefix)
        
        // classes that we create from dictionaries. they dont exist in swift files, but will exist in realm.
        let nestedCreatedTMAPClassess = nestedClasses
            .filter { !exceptions.contains($0.name) }
            .map { triftClass -> ContentFile in
                let content  = tmapConverter.createCodeForClass(thriftClass: triftClass)
                let fileName = filesPrefix + triftClass.name.trimmingCharacters(in: .whitespaces) + "TMapMapper.swift"
                return ContentFile(name: fileName, content: content)
        }
        
        return normalClasses + nestedCreatedTMAPClassess
    }
    
    public func createBaseClasses() -> [ContentFile] {
        
        let mapperProtocol = ContentFile(name: "MapperProtocol.swift", content: """
import RealmSwift
import Thrift


public protocol MapperProtocol {
    associatedtype APIEntity: AnyObject
    associatedtype RealmEntity: Object
    
    init()
    func map(apiEntity: APIEntity, into entity: RealmEntity) -> RealmEntity
    func map(entity: RealmEntity, into apiEntity: APIEntity) -> APIEntity
    func map(entity: RealmEntity?) -> APIEntity?
}


""")
        let tmapmapperProtocol = ContentFile(name: "TMapMapperProtocol.swift", content: """
import RealmSwift
import Thrift


public protocol TMapMapperProtocol {
    associatedtype Key: Any
    associatedtype Value: Any
    associatedtype RealmEntity: Object

    typealias apiEntity = (key: Key, value: Value)

    init()
    func map(apiEntity: apiEntity, into entity: RealmEntity) -> RealmEntity
    func map(entity: RealmEntity) -> apiEntity
}


""")
        let realmLoader = ContentFile(name: "RealmLoader.swift", content: """
import RealmSwift


public final class RealmLoader {
    public static let shared = RealmLoader()
    // Initialize this in AppDelegate or before db usage
    public var key: Data!

    public func loadRealm() throws -> Realm {
        
        let configuration = Realm.Configuration(encryptionKey: key)
        do {
            let realm = try Realm(configuration: configuration)
            return realm
        }
        catch  {
            throw KZDataModelError.decryptionFailed
        }
    }
}

enum KZDataModelError: Error {
    case decryptionFailed
}

""")
        
        let classes: [ContentFile] = [
            mapperProtocol,
            tmapmapperProtocol,
            realmLoader
        ]
        
        return classes
    }
    
}

