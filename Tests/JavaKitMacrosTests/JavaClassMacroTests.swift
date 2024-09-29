@testable import JavaKitMacros
import MacroTesting
import Testing

@Suite
struct JavaClassMacroTests {
  @Test
  func classMacro() throws {
    assertMacro([JavaClassMacro.self]) {
      """
      @JavaClass("org.swift.example.HelloSwift", extends: JavaString.self)
      struct HelloSwift {
      }
      """
    } expansion: {
      """
      struct HelloSwift {

          /// The full Java class name for this Swift type.
          public static var fullJavaClassName: String {
              "org.swift.example.HelloSwift"
          }

          public typealias JavaSuperclass = JavaString

          public var javaHolder: JavaObjectHolder

          public var javaThis: jobject {
            javaHolder.object!
          }

          public var javaEnvironment: JNIEnvironment {
            javaHolder.environment
          }

          public init(javaHolder: JavaObjectHolder) {
              self.javaHolder = javaHolder
          }
      }
      """
    }
  }

  @Test
  func fieldMacro() throws {
    assertMacro([JavaFieldMacro.self]) {
      """
      @JavaField
      var counter: Int32
      """
    } expansion: {
      """
      var counter: Int32 {
          get {
              self[javaFieldName: "counter", fieldType: Int32.self]
          }
          nonmutating set {
              self[javaFieldName: "counter", fieldType: Int32.self] = newValue
          }
      }
      """
    }
  }

  @Test
  func methodMacro() {
    assertMacro([JavaMethodMacro.self]) {
      """
      @JavaMethod
      init(name: String, environment: JNIEnvironment)
      """
    } expansion: {
      """
      init(name: String, environment: JNIEnvironment) {
          self = try! Self.dynamicJavaNewObject(in: environment, arguments: name.self)
      }
      """
    }
  }

  @Test
  func methodMacro_InitWithoutEnvironment() {
    assertMacro([JavaMethodMacro.self]) {
      """
      @JavaMethod
      init(name: String)
      """
    } diagnostics: {
      """
      @JavaMethod
      ┬──────────
      ╰─ 🛑 missingEnvironment
      init(name: String)
      """
    }
  }

  @Test
  func methodMacroThrowing() {
    assertMacro([JavaMethodMacro.self]) {
      """
      @JavaMethod
      func hello() throws
      """
    } expansion: {
      """
      func hello() throws {
          return try dynamicJavaMethodCall(methodName: "hello")
      }
      """
    }
  }
}
