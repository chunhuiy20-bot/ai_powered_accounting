# Flutter 应用开发

## 1、 一些基本知识

### lib/main.dart

1、main() 函数	所有 Dart 和 Flutter 程序的起点。runApp() 在这里被调用，用于启动 Flutter 应用。  
2、runApp()	Flutter 框架提供的函数，它接收一个 Widget 作为参数，并将这个 Widget 作为应用的根视图显示在屏幕上  
3、Widget (组件)	Flutter 中 UI 的基本构建块。你看到的一切几乎都是 Widget，它们可以嵌套组合，形成一个“组件树”。  
4、StatelessWidget	“无状态组件”，一种不依赖于自身状态变化的 Widget。它的所有数据都通过构造函数传入，一旦创建，其内部数据就不会再改变。MyApp 就是一个典型的例子。  
5、build() 方法	每个 Widget 都必须实现的核心方法。Flutter 框架在需要渲染界面时会调用它，它返回一个描述如何绘制 UI 的 Widget。  
6、MaterialApp	一个非常重要的顶层 Widget，它封装了实现 Material Design 风格应用所需的许多功能，如主题、路由导航、本地化等。  
7、ThemeData	用于定义整个应用的视觉主题，包括颜色、字体、组件样式等。这使得应用风格统一，且易于管理和切换。  