#!/usr/bin/swift sh

//Append Final
//By adding final to a class it will remove the overhead to check for method overriding functions.
//Algorithm
/*
1. Scan all files inside folder.
2. File extension should be swift
3. If that file doesn't have open access modifier
4) Whether final keyword is already there.
5) We need to find the class name.
6) Store that [className:File] in a dictionary
7) Iterate dictionary and search that file is subclassed or not
8) If that file is not subclassed then add final keyword to that class
*/

let folder = Folder.current

func scanFolders(){ // We are scanning all folders
    var dict: [String: File] = [:]
    folder.makeSubfolderSequence(recursive: true).forEach { folderOuter in
        for file in folderOuter.files {
            // Checking for extensions
            if file.extension == "swift" || file.extension ==
            "m"{
                do {
                    //Read file content and convert it to a string
                    let content = try file.readAsString()
                    let openContainingPattern = "open \\s*class"
                    let openRange = content.range(of: openContainingPattern, options:.regularExpression)
                    if openRange != nil{
                        continue
                    }
                    let finalContainingPattern = "final \\s*class"
                    let finalRange = content.range(of: finalContainingPattern, options:.regularExpression)
                    if finalRange != nil{
                        continue
                    }
                    //Comparing regex to find the className
                    let pattern = "class \\s*.*\\s*:"
                    if let range = content.range(of: pattern, options:.regularExpression){
                        //Finding the className
                        let className = fetchClassName(content: content, range: range)
                        //Storing className in dictionary
                        dict[className] = file
                    }
                }catch{}
            }
        }
    }
    test.appendFinal(dict: dict, folder: folder)
}

func appendFinal(dict: [String: File], folder: Folder){
    for param in dict.enumerated(){
        let file = param.element.value
        let className = param.element.key
        let isInherited = test.searchSubFolders(class: param.element.key, folder: folder)
        if !isInherited{
            do {
                let content = try file.readAsString()
                print("\(className)")
                let finalContent = content.replacingOccurrences(of: "class \(className)", with: " final class \(className)")
                try file.write(string: finalContent)
            }catch{}
        }
    }
}

func searchSubFolders(class name: String, folder: Folder) -> Bool{
    var isInherited = false
    folder.makeSubfolderSequence(recursive: true).forEach { folderInner in
        for innerFile in folderInner.files{
            if innerFile.extension == "swift" || innerFile.extension == "h" || innerFile.extension == "m" {
                do {
                    let innerContent = try innerFile.readAsString()
                    let antiPattern = ":\\s*.*"
                    if let range = innerContent.range(of: antiPattern, options:.regularExpression){
                        let str = innerContent[range]
                        if str.contains(name){
                            isInherited = true
                        }
                    }
                }catch{}
            }
        }
    }
   return isInherited
}

func fetchClassName(content: String,range: Range<String.Index>) -> String{
    let string = content[range]
    let pattern = ":.*\\s*"
    var className = ""
    if let range = string.range(of: pattern, options:.regularExpression){
        let  name =  string[range]
        className = string.replacingOccurrences(of: name, with: "")
    }
     className = className.replacingOccurrences(of: "class", with: "")
    className = className.replacingOccurrences(of: " ", with: "")
    className = className.replacingOccurrences(of: ":", with: "")
    return className
}

test.scanFolders()
