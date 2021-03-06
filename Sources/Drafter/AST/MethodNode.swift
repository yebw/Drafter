//
//  MethodNode.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - MethodNode

/// 方法定义
class MethodNode: Node {
    var isSwift = false  // 是否为swift方法
    var isStatic = false  // 是否为类方法
    var returnType: String = "" // 返回值类型
    var methodName: String = "" 
    var params: [Param] = [] // 方法的参数
    var invokes: [MethodInvokeNode] = [] // 该方法中调用的OC方法
    var methodBody: [Token] = [] // 函数体的源码
}

// MARK: - Param

struct Param {
    var type: String = "" // 参数类型
    var outterName: String = "" // 参数的名字
    var innerName: String = "" // 内部形参的名字
}

extension Param {
    init(type: String, outter: String, inner: String) {
        self.init()
        self.type = type
        self.outterName = outter
        self.innerName = inner
    }
}

// MARK: - CustomStringConvertible

extension MethodNode: CustomStringConvertible {
    var description: String {
        if isSwift {
            return swiftDescription
        } else {
            return objcDescription
        }
    }
    
    /// 格式化成OC风格
    var objcDescription: String {
        var method = "\(isStatic ? "+" : "-") ["
        
        let methodDesc = params.join(stringify: { (param) -> String in
            if !param.innerName.isEmpty {
                return "\(param.outterName): "
            } else {
                return param.outterName
            }
        }, separator: " ")
        method.append(contentsOf: "\(methodDesc)]")
        
        return method
    }
    
    /// 格式化成swift风格
    var swiftDescription: String {
        var method = ""
        
        if methodName != "init" {
            method.append(contentsOf: "func ")
        }
        method.append(contentsOf: "\(methodName)(")
        
        if isStatic {
            method.insert(contentsOf: "static ", at: method.startIndex)
        }
        
        let paramStr = params.join(stringify: { (param) -> String in
            return "\(param.outterName): "
        }, separator: ", ")
        method.append(contentsOf: "\(paramStr))")
        
        return method
    }
}

// MARK: - Hashable

extension MethodNode: Hashable {
    
    static func ==(_ left: MethodNode, _ right: MethodNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    /// 目前swift和oc之间不能判等
    var hashValue: Int {
        if isSwift {
            return swiftHashValue
        } else {
            return objcHashValue
        }
    }
    
    var objcHashValue: Int {
        var value = ""
        for param in params {
            value.append(contentsOf: param.outterName)
            if !param.innerName.isEmpty {
                value.append(contentsOf: ":")
            }
        }
        return value.hashValue
    }
    
    var swiftHashValue: Int {
        let paramSign = params.join(stringify: { (param) -> String in
            return "\(param.outterName):"
        }, separator: ",")
        let methodSign = "\(methodName)\(paramSign)"
        
        return methodSign.hashValue
    }
}
