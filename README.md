# ThriftConvertor
ThritConvertor -  create needed Realm classes from Thrift classes (and mappers to convert them in both directions)
Top class is CodeConverter

Example usage: 

        
        //get .thrift file into String
        let text         = try! String(contentsOf: fileURL)
        
        //create converter using files prefix if needed, some exceptions classes
        let converter    = CodeConverter(prefix: prefix, exceptionNames: [])
        
        //create realm classes from converter into [ContentFile] 
        let realmClasses = converter.createRealmClasses(thriftText: text)
        
        //create mappers between Realm and Thrift objects if needed
        let mappers      = converter.createMapperClasses(thriftText: text)

        //create some base classes and protocols to make everything work
        let bases        = converter.createBaseClasses()
        
        //call base thrift->swift generate utility from Apache
        createBasicThriftGeneratedFiles(fileURL: fileURL)

## Contacts

Aleksandr Zaporozhchenko
[[github]](https://github.com/Maxatma)  [[gmail]](mailto:maxatma.ids@gmail.com)  [[fb]](https://www.facebook.com/profile.php?id=100008291260780)  [[in]](https://www.linkedin.com/in/maxatma/)
