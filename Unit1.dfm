object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 438
  ClientWidth = 876
  Color = clBtnFace
  UseDockManager = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 416
    Width = 703
    Height = 19
  end
  object Image2: TImage
    Left = 2
    Top = 275
    Width = 640
    Height = 120
    DragCursor = crHSplit
    DragKind = dkDock
    Stretch = True
    OnMouseLeave = Image2MouseLeave
    OnMouseMove = Image2MouseMove
  end
  object Label2: TLabel
    Left = 167
    Top = 421
    Width = 41
    Height = 13
    Caption = 'Elapsed:'
  end
  object Image3: TImage
    Left = 643
    Top = 17
    Width = 29
    Height = 256
  end
  object Label3: TLabel
    Left = 8
    Top = 421
    Width = 49
    Height = 14
    Caption = 'Offset:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 271
    Top = 421
    Width = 31
    Height = 13
    Caption = 'Label4'
  end
  object Label5: TLabel
    Left = 527
    Top = 421
    Width = 47
    Height = 13
    Caption = 'Selection:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 15
    Align = alCustom
    BevelInner = bvLowered
    BevelOuter = bvLowered
    Color = clMedGray
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 640
      Height = 13
      Align = alCustom
      BevelKind = bkFlat
      BevelOuter = bvSpace
      Color = clSkyBlue
      Constraints.MinWidth = 10
      TabOrder = 0
      OnMouseDown = Panel2MouseDown
      OnMouseMove = Panel2MouseMove
      OnMouseUp = Panel2MouseUp
    end
  end
  object TabControl1: TTabControl
    Left = 709
    Top = 0
    Width = 167
    Height = 438
    Align = alRight
    MultiLine = True
    TabOrder = 1
    TabPosition = tpLeft
    Tabs.Strings = (
      'Controls')
    TabIndex = 0
    object Label1: TLabel
      Left = 76
      Top = 144
      Width = 72
      Height = 13
      Caption = 'Zoom out: 2^0'
    end
    object SpeedButton1: TSpeedButton
      Left = 27
      Top = 3
      Width = 29
      Height = 23
      Hint = 'Zoom In'
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 59
      Top = 3
      Width = 29
      Height = 23
      Hint = 'Zoom Out'
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton2Click
    end
    object SpeedButton3: TSpeedButton
      Left = 91
      Top = 3
      Width = 29
      Height = 23
      Hint = 'Zoom Out (Full)'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton3Click
    end
    object SpeedButton5: TSpeedButton
      Left = 60
      Top = 32
      Width = 29
      Height = 23
      Hint = 'Play'
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton4Click
    end
    object CheckBox1: TCheckBox
      Left = 11
      Top = 226
      Width = 97
      Height = 17
      Caption = 'Show maximum'
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 11
      Top = 163
      Width = 83
      Height = 17
      Caption = 'Anti - aliasing'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = CheckBox2Click
    end
    object TrackBar1: TTrackBar
      Left = 126
      Top = -1
      Width = 38
      Height = 139
      Align = alCustom
      Max = 0
      Min = -8
      Orientation = trVertical
      TabOrder = 2
      TickMarks = tmBoth
      OnChange = TrackBar1Change
    end
    object ComboBox1: TComboBox
      Left = 19
      Top = 186
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 4
      TabOrder = 3
      Text = '256'
      Items.Strings = (
        '16'
        '32'
        '64'
        '128'
        '256'
        '512'
        '1024'
        '2048'
        '4096'
        '8192'
        '16384')
    end
    object RadioGroup1: TRadioGroup
      Left = 11
      Top = 249
      Width = 107
      Height = 64
      Caption = 'On Wheel'
      ItemIndex = 0
      Items.Strings = (
        'Zoom'
        'Scroll')
      TabOrder = 4
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 15
    Width = 644
    Height = 259
    TabOrder = 2
    object Image1: TImage
      Left = 2
      Top = 2
      Width = 640
      Height = 256
      OnClick = Image1Click
      OnMouseDown = Image1MouseDown
      OnMouseEnter = Image1MouseEnter
      OnMouseMove = Image1MouseMove
      OnMouseUp = Image1MouseUp
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 88
    Top = 310
  end
  object MainMenu1: TMainMenu
    Left = 128
    Top = 312
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open...'
        OnClick = Button1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object Frequencyanalysis1: TMenuItem
        Caption = 'Frequency analysis'
        Checked = True
      end
      object Controls1: TMenuItem
        Caption = 'Controls'
        Checked = True
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 20
    OnTimer = Timer1Timer
    Left = 160
    Top = 312
  end
end