object DemoWebModule: TDemoWebModule
  Actions = <
    item
      MethodType = mtGet
      Name = 'HelloWebActionItem'
      PathInfo = '/hellowm'
      OnAction = DemoWebModuleHelloWebActionItemAction
    end>
  Height = 461
  Width = 1173
  PixelsPerInch = 192
end
