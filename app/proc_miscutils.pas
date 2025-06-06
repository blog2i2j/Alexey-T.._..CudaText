(*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) Alexey Torgashin
*)
unit proc_miscutils;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
{$ScopedEnums on}

interface

uses
  {$ifdef windows}
  Windows, Messages,
  {$endif}
  Classes, SysUtils, Controls, StdCtrls, ComCtrls, Graphics, Types,
  ImgList, Dialogs, Forms, Menus, ExtCtrls, Math,
  LclIntf, LclType, LazFileUtils, StrUtils,
  Clipbrd,
  BGRABitmap,
  appjsonconfig,
  ATSynEdit,
  ATSynEdit_Globals,
  ATSynEdit_Adapter_EControl,
  ATSynEdit_Finder,
  ATStringProc,
  ATStringProc_Separator,
  ATStringProc_HtmlColor,
  ATListbox,
  ATPanelSimple,
  ATButtons,
  ATGauge,
  ATFlatToolbar,
  ATBinHex,
  ATImageBox,
  ec_SyntAnal,
  ec_syntax_format,
  proc_globdata,
  proc_py_const,
  proc_colors;

function FormPosGetAsString(Form: TForm; AOnlySize: boolean): string;
procedure FormPosSetFromString(Form: TForm; const S: string; AOnlySize: boolean; const ADesktopRect: TRect);
procedure RectSetFromString(var R: TRect; const S: string; AOnlySize: boolean; const ADesktopRect: TRect);

procedure AppListbox_CopyOneLine(L: TATListbox);
procedure AppListbox_CopyAllLines(L: TATListbox);
procedure AppListbox_Clear(L: TATListbox);

procedure FormLock(Ctl: TForm);
procedure FormUnlock(Ctl: TForm);
//procedure ControlAutosizeOnlyByWidth(C: TWinControl);

procedure FormHistorySave(F: TForm; const AConfigPath: string; AWithPos: boolean);
procedure FormHistoryLoad(F: TForm; const AConfigPath: string; AWithPos: boolean; const ADesktopRect: TRect);

procedure FormPutToVisibleArea(F: TForm);

function Canvas_TextMultilineExtent(C: TCanvas; const AText: string): TPoint;
function Canvas_NumberToFontStyles(Num: integer): TFontStyles;
procedure Canvas_PaintPolygonFromSting(C: TCanvas; const AText: string);
procedure Canvas_PaintImageInRect(C: TCanvas; APic: TGraphic; const ARect: TRect);
function DoPictureLoadFromFile(const AFilename: string): TGraphic;
function DoClipboardSavePictureToFile(const fn: string): boolean;
function DoClipboardFormatsAsString: string;

procedure AppScalePanelControls(APanel: TWinControl);
procedure AppScaleSplitter(C: TSplitter);
procedure AppInitProgressForm(out AForm: TForm; out AProgress: TATGauge;
  out AButtonCancel: TATButton; const AText: string);
function AppValidateJson(const AText: string): boolean;
function AppCountCommandlineFilenames(const Ar: array of string): integer;

procedure LexerEnumSublexers(An: TecSyntAnalyzer; List: TStringList);
procedure LexerEnumStyles(An: TecSyntAnalyzer; List: TStringList);
function LexerFilenameToComponentName(const fn: string): string;

type
  TAppTreeGoto = (
    Next,
    Prev,
    Parent,
    NextBro,
    PrevBro
    );

procedure DoTreeviewJump(ATree: TTreeView; AMode: TAppTreeGoto);
procedure DoTreeviewFoldLevel(ATree: TTreeView; ALevel: integer);
procedure DoTreeviewCopy(Src, Dst: TTreeView);

procedure ApplyThemeToTreeview(C: TTreeview; AThemed, AChangeShowRoot: boolean);
procedure ApplyThemeToToolbar(C: TATFlatToolbar);
procedure ApplyThemeToImageBox(AImageBox: TATImageBox);

function ConvertTwoPointsToDiffPoint(APrevPnt, ANewPnt: TPoint): TPoint;
function ConvertShiftStateToString(const Shift: TShiftState): string;
function KeyboardStateToShiftState: TShiftState; //like VCL
function UpdateImagelistWithIconFromFile(AList: TCustomImagelist;
  const AFilename, ACallerAPI: string; AllowScaling: boolean=false): integer;
function FormatFileDateAsNiceString(const AFilename: string): string;
function FormatFilenameForMenu(const fn: string): string;

function AppNicePluginCaption(const S: string): string;
function AppStrToBool(const S: string): boolean; inline;
function AppStringToAlignment(const S: string): TAlignment;
function AppAlignmentToString(const V: TAlignment): string;
function AppGetLeveledPath(const AFileName: string; ALevel: integer): string;
function IsPointsDiffByDelta(const P1, P2: TPoint; Delta: integer): boolean;

function ViewerGotoFromString(V: TATBinHex; const SInput: string): boolean;
procedure ApplyThemeToViewer(V: TATBinHex);

function ExtractFileName_Fixed(const FileName: string): string;
function ExtractFileDir_Fixed(const FileName: string): string;

procedure DoPaintCheckers(C: TCanvas;
  ASizeX, ASizeY: integer;
  ACellSize: integer;
  AColor1, AColor2: TColor);
procedure DoFormFocus(F: TForm; AllowShow: boolean);

procedure Menu_Copy(ASrc, ADest: TMenu);
function Menu_GetIndexToInsert(AMenu: TMenuItem; ACaption: string): integer;
procedure MenuShowAtEditorCorner(AMenu: TPopupMenu; Ed: TATSynEdit);

function StringToIntArray(const AText: string): TATIntArray;
function IntArrayToString(const A: TATIntArray): string;
function IsStringArrayWithSubstring(const Ar: array of string; const AText: string): boolean;

function FinderOptionsToString(F: TATEditorFinder): string;
procedure FinderOptionsFromString(F: TATEditorFinder; const S: string);

function MultiSelectStyleToString(St: TMultiSelectStyle): string;
function StringToMultiSelectStyle(const S: string): TMultiSelectStyle;

type
  { TAppPanelEx }

  TAppPanelEx = class(TPanel)
  public
    ColorFrame: TColor;
    PaddingX: integer;
    PaddingY: integer;
    constructor Create(TheOwner: TComponent); override;
    procedure Paint; override;
  end;

type
  { TAppSplitter }

  TAppSplitter = class(TSplitter)
  public
    CustomColored: boolean;
    procedure Paint; override;
  end;

var
  HtmlTags: TStringList = nil;

procedure InitHtmlTags;
procedure StringsDeduplicate(L: TStringList; CaseSens: boolean);
function StringsTrailingText(L: TStringList; AItemCount: integer): string;
function ConvertCssColorToTColor(const S: string): TColor;

type
  { TAppCodetreeSavedFold }

  TAppCodetreeSavedFold = record
  private
    Cap, Cap2: string;
  public
    procedure Save(Ed: TATSynEdit; ATree: TTreeView);
    procedure Restore(Ed: TATSynEdit; ATree: TTreeView);
  end;


implementation

procedure LexerEnumSublexers(An: TecSyntAnalyzer; List: TStringList);
var
  i: Integer;
  AnLink: TecSyntAnalyzer;
begin
  List.Clear;
  for i:= 0 to An.SubAnalyzers.Count-1 do
  begin
    AnLink:= An.SubAnalyzers[i].SyntAnalyzer;
    if AnLink<>nil then
      List.Add(AnLink.LexerName)
    else
      List.Add('');
  end;
end;

procedure LexerEnumStyles(An: TecSyntAnalyzer; List: TStringList);
var
  i: Integer;
begin
  List.Clear;
  for i:= 0 to An.Formats.Count-1 do
    List.Add(An.Formats[i].DisplayName);
end;

procedure DoTreeviewJump(ATree: TTreeView; AMode: TAppTreeGoto);
var
  tn, tn2: TTreeNode;
begin
  with ATree do
    if Selected<>nil then
    begin
      case AMode of
        TAppTreeGoto.Next:
          tn:= Selected.GetNext;
        TAppTreeGoto.Prev:
          tn:= Selected.GetPrev;
        TAppTreeGoto.Parent:
          tn:= Selected.Parent;
        TAppTreeGoto.NextBro:
          begin
            tn:= Selected.GetNextSibling;
            tn2:= Selected;
            if tn=nil then
              repeat
                tn2:= tn2.Parent;
                if tn2=nil then Break;
                tn:= tn2.GetNextSibling;
                if tn<>nil then Break;
              until false;
          end;
        TAppTreeGoto.PrevBro:
          begin
            tn:= Selected.GetPrevSibling;
            if tn=nil then
              tn:= Selected.Parent;
          end;
        else tn:= nil;
      end;
      if tn<>nil then
      begin
        Selected:= tn;
        ATree.OnDblClick(nil);
      end;
    end;
end;


function ConvertTwoPointsToDiffPoint(APrevPnt, ANewPnt: TPoint): TPoint;
begin
  if APrevPnt.Y=ANewPnt.Y then
  begin
    Result.Y:= 0;
    Result.X:= ANewPnt.X-APrevPnt.X;
  end
  else
  begin
    Result.Y:= ANewPnt.Y-APrevPnt.Y;
    Result.X:= ANewPnt.X;
  end;
end;

function KeyboardStateToShiftState: TShiftState;
begin
  Result:= [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
  if GetKeyState(VK_LWIN) < 0 then Include(Result, ssMeta);
  if GetKeyState(VK_LBUTTON) < 0 then Include(Result, ssLeft);
  if GetKeyState(VK_RBUTTON) < 0 then Include(Result, ssRight);
  if GetKeyState(VK_MBUTTON) < 0 then Include(Result, ssMiddle);
  if GetKeyState(VK_XBUTTON1) < 0 then Include(Result, ssExtra1);
  if GetKeyState(VK_XBUTTON2) < 0 then Include(Result, ssExtra2);
end;

function ConvertShiftStateToString(const Shift: TShiftState): string;
begin
  Result:= '';
  if ssShift in Shift then Result+= 's';
  if ssCtrl in Shift then Result+= 'c';
  if ssAlt in Shift then Result+= 'a';
  if ssMeta in Shift then Result+= 'm';
  if ssLeft in Shift then Result+= 'L';
  if ssRight in Shift then Result+= 'R';
  if ssMiddle in Shift then Result+= 'M';
  if ssExtra1 in Shift then Result+= '4';
  if ssExtra2 in Shift then Result+= '5';
end;


function UpdateImagelistWithIconFromFile(AList: TCustomImagelist;
  const AFilename, ACallerAPI: string; AllowScaling: boolean=false): integer;
var
  bgra: TBGRABitmap;
  bmp: TCustomBitmap;
  ext: string;
begin
  Result:= -1;
  if AFilename='' then exit;
  if not FileExists(AFilename) then
  begin
    MsgLogConsole('ERROR: Missing icon filename in '+ACallerAPI+': '+AFilename);
    exit;
  end;

  ext:= ExtractFileExt(AFilename);

  try
    if ext='.png' then
    begin
      bgra:= TBGRABitmap.Create;
      try
        bgra.LoadFromFile(AFilename);
        if AllowScaling then
          if (bgra.Width<>AList.Width) then
            BGRAReplace(bgra, bgra.Resample(AList.Width, AList.Height));
        AList.Add(bgra.Bitmap, nil);
      finally
        FreeAndNil(bgra);
      end;
    end
    else
    if ext='.bmp' then
    begin
      bmp:= TBitmap.Create;
      try
        bmp.LoadFromFile(AFilename);
        bmp.Transparent:= true;
        AList.Add(bmp, nil);
      finally
        FreeAndNil(bmp);
      end;
    end
    else
    begin
      MsgLogConsole('ERROR: Unknown icon file type in '+ACallerAPI+': '+AFilename);
      exit;
    end;

    Result:= AList.Count-1;
  except
    MsgLogConsole('ERROR: Error loading icon from file: '+AFilename);
  end;
end;

function Canvas_NumberToFontStyles(Num: integer): TFontStyles;
begin
  Result:= [];
  if (Num and FONT_B)<>0 then Include(Result, fsBold);
  if (Num and FONT_I)<>0 then Include(Result, fsItalic);
  if (Num and FONT_U)<>0 then Include(Result, fsUnderline);
  if (Num and FONT_S)<>0 then Include(Result, fsStrikeOut);
end;

procedure Canvas_PaintPolygonFromSting(C: TCanvas; const AText: string);
var
  Sep: TATStringSeparator;
  P: TPoint;
  Pnt: array of TPoint;
begin
  Pnt:= nil;
  Sep.Init(AText);
  repeat
    if not Sep.GetItemInt(P.X, MaxInt) then Break;
    if not Sep.GetItemInt(P.Y, MaxInt) then Break;
    if (P.X=MaxInt) then Exit;
    if (P.Y=MaxInt) then Exit;
    SetLength(Pnt, Length(Pnt)+1);
    Pnt[Length(Pnt)-1]:= P;
  until false;

  if Length(Pnt)>2 then
    C.Polygon(Pnt);
end;


function DoPictureLoadFromFile(const AFilename: string): TGraphic;
var
  ext: string;
  ImageEx: TBGRABitmap;
  Bmp: TBitmap;
begin
  Result:= nil;
  if not FileExists(AFilename) then exit;
  ext:= LowerCase(ExtractFileExt(AFilename));

  if ext='.png' then
    Result:= TPortableNetworkGraphic.Create
  else
  if ext='.gif' then
    Result:= TGIFImage.Create
  else
  if ext='.bmp' then
    Result:= TBitmap.Create
  else
  if (ext='.jpg') or (ext='.jpeg') or (ext='.jfif') then
    Result:= TJPEGImage.Create
  else
  if ext='.webp' then
  try
    ImageEx:= nil; //important, init it for the case of exception in TBGRABitmap.Create()
    ImageEx:= TBGRABitmap.Create(AFilename);
    if not Assigned(ImageEx) then exit;
    Bmp:= TBitmap.Create;
    Bmp.PixelFormat:= pf24bit;
    Bmp.Transparent:= true;
    Bmp.SetSize(ImageEx.Width, ImageEx.Height);
    ImageEx.Draw(Bmp.Canvas, 0, 0, True);
    Result:= Bmp;
    exit;
  finally
    if Assigned(ImageEx) then
      FreeAndNil(ImageEx);
  end
  else
    exit;

  try
    Result.LoadFromFile(AFilename);
    Result.Transparent:= true;
  except
    FreeAndNil(Result);
  end;
end;


function DoClipboardSavePictureToFile(const fn: string): boolean;
begin
  if Clipboard.HasPictureFormat then
  begin
    if FileExists(fn) then
      DeleteFileUTF8(fn);
    with TPicture.Create do
    try
      Assign(Clipboard);
      SaveToFile(fn);
    finally
      Free;
    end;
    Result:= FileExists(fn);
  end
  else
    Result:= false;
end;


procedure Canvas_PaintImageInRect(C: TCanvas; APic: TGraphic; const ARect: TRect);
var
  Bitmap: TBitmap;
begin
  Bitmap:= TBitmap.Create;
  try
    Bitmap.PixelFormat:= pf24bit;
    Bitmap.SetSize(APic.Width, APic.Height);
    Bitmap.Canvas.Brush.Color:= clWhite;
    Bitmap.Canvas.FillRect(0, 0, Bitmap.Width, Bitmap.Height);
    Bitmap.Canvas.Draw(0, 0, APic);
    C.AntialiasingMode:= amOn;
    C.StretchDraw(ARect, Bitmap);
  finally
    FreeAndNil(Bitmap);
  end;
end;


function ConvertDateTimeToNiceString(const ADate: TDateTime): string;
var
  DTime: TDateTime;
  NHour, NMinute, NSec, NMilSec: word;
begin
  //fix result: make millisec=0, make seconds even int
  DecodeTime(ADate, NHour, NMinute, NSec, NMilSec);
  NMilSec:= 0;
  //NSec:= NSec div 2 * 2;
  DTime:= EncodeTime(NHour, NMinute, NSec, NMilSec);
  Result:= FormatDateTime('yyyy-mm-dd_hh-nn-ss', ComposeDateTime(ADate, DTime));
end;

function FormatFileDateAsNiceString(const AFilename: string): string;
var
  NValue: Longint;
  D: TDateTime;
begin
  NValue:= FileAgeUTF8(AFilename);
  if NValue<0 then exit('');
  D:= FileDateToDateTime(NValue);
  Result:= ConvertDateTimeToNiceString(D);
end;


procedure ApplyThemeToTreeview(C: TTreeview; AThemed, AChangeShowRoot: boolean);
var
  Op: TTreeViewOptions;
begin
  if AThemed then
  begin
    C.Font.Name:= UiOps.VarFontName;
    C.Font.Size:= ATEditorScaleFont(UiOps.VarFontSize);
    C.Font.Color:= GetAppColor(TAppThemeColor.TreeFont);
    C.BackgroundColor:= GetAppColor(TAppThemeColor.TreeBg);
    C.SelectionFontColor:= GetAppColor(TAppThemeColor.TreeSelFont);
    C.SelectionFontColorUsed:= true;
    if C.Focused then
      C.SelectionColor:= GetAppColor(TAppThemeColor.TreeSelBg)
    else
      C.SelectionColor:= GetAppColor(TAppThemeColor.TreeSelBg2);
    C.TreeLinePenStyle:= psSolid;
    C.ExpandSignColor:= GetAppColor(TAppThemeColor.TreeSign);
  end;

  C.BorderStyle:= bsNone;
  C.ExpandSignType:= tvestArrowFill;

  Op:= [
    tvoAutoItemHeight,
    tvoKeepCollapsedNodes,
    tvoShowButtons,
    tvoRowSelect,
    tvoRightClickSelect,
    tvoReadOnly,
    tvoNoDoubleClickExpand
    ];

  if AChangeShowRoot or C.ShowRoot then
    Include(Op, tvoShowRoot)
  else
    Exclude(Op, tvoShowRoot);

  {
  if UiOps.TreeShowLines then
    Include(Op, tvoShowLines)
  else
    Exclude(Op, tvoShowLines);
  }

  if UiOps.TreeShowTooltips then
    Include(Op, tvoToolTips)
  else
    Exclude(Op, tvoToolTips);

  C.Options:= Op;

  if AThemed then
    C.ScrollBars:= ssNone
  else
    C.ScrollBars:= ssVertical;

  C.Invalidate;
end;



procedure ApplyThemeToToolbar(C: TATFlatToolbar);
begin
  C.Color:= GetAppColor(TAppThemeColor.TabBg);
  C.Invalidate;
end;

function DoClipboardFormatsAsString: string;
begin
  Result:= '';
  if Clipboard.HasFormat(CF_Text) then
    Result+= 't';
  if Clipboard.HasFormat(CF_HTML) then
    Result+= 'h';
  if Clipboard.HasPictureFormat then
    Result+= 'p';

  if Clipboard.HasFormat(ATEditorOptions.ClipboardColumnFormat) then
    Result+= 'c';
  if Clipboard.HasFormat(ATEditorOptions.ClipboardExFormat) then
    Result+= 'x';
end;

procedure AppScalePanelControls(APanel: TWinControl);
var
  Ctl: TControl;
  i: integer;
begin
  for i:= 0 to APanel.ControlCount-1 do
  begin
    Ctl:= APanel.Controls[i];

    if (Ctl is TATButton) or (Ctl is TATPanelSimple) then
    begin
      Ctl.Width:= ATEditorScale(Ctl.Width);
      Ctl.Height:= ATEditorScale(Ctl.Height);
    end;

    if Ctl is TATPanelSimple then
      AppScalePanelControls(Ctl as TATPanelSimple)
  end;
end;

function AppStrToBool(const S: string): boolean; inline;
begin
  Result:= S='1';
end;


procedure DoTreeviewFoldLevel(ATree: TTreeView; ALevel: integer);
var
  Node: TTreeNode;
  i: integer;
begin
  ATree.Items.BeginUpdate;
  ATree.FullExpand;
  try
    for i:= 0 to ATree.Items.Count-1 do
    begin
      Node:= ATree.Items[i];
      if Node.Level>=ALevel-1 then
        Node.Collapse(true);
    end;
  finally
    ATree.Items.EndUpdate;
  end;
end;


function ExtractFileName_Fixed(const FileName: string): string;
var
  EndSep: Set of Char;
  I: integer;
begin
  I := Length(FileName);
  EndSep:= AllowDirectorySeparators; //dont include ":", needed for NTFS streams
  while (I > 0) and not CharInSet(FileName[I],EndSep) do
    Dec(I);
  Result := Copy(FileName, I + 1, MaxInt);
end;

function ExtractFileDir_Fixed(const FileName: string): string;
var
  EndSep: Set of Char;
  I: integer;
begin
  I := Length(FileName);
  EndSep:= AllowDirectorySeparators; //dont include ":", for ntfs streams
  while (I > 0) and not CharInSet(FileName[I],EndSep) do
    Dec(I);
  if (I > 1) and CharInSet(FileName[I],AllowDirectorySeparators) and
     not CharInSet(FileName[I - 1],EndSep) then
    Dec(I);
  Result := Copy(FileName, 1, I);
end;


procedure DoTreeviewCopy(Src, Dst: TTreeView);
var
  SrcItem, DstItem: TTreeNode;
  R, R2: TATRangeInCodeTree;
  i: integer;
begin
  Dst.BeginUpdate;
  try
    Dst.Items.Assign(Src.Items);

    {
    //causes exception 'Control "" has no parent window" when called from TfmMain.DoOnTabFocus
    if Assigned(Src.Selected) then
      Dst.Selected:= Dst.Items[Src.Selected.AbsoluteIndex];
      }

    for i:= 0 to Src.Items.Count-1 do
    begin
      SrcItem:= Src.Items[i];
      DstItem:= Dst.Items[i];

      DstItem.Expanded:= SrcItem.Expanded;

      //copying of Item.Data, must create new range
      if SrcItem.Data<>nil then
        if TObject(SrcItem.Data) is TATRangeInCodeTree then
        begin
          R:= TATRangeInCodeTree(SrcItem.Data);
          R2:= TATRangeInCodeTree.Create;
          R2.Assign(R);
          DstItem.Data:= R2;
        end;
    end;
  finally
    Dst.EndUpdate;
  end;
end;


function ViewerGotoFromString(V: TATBinHex; const SInput: string): boolean;
var
  Num: Int64;
begin
  Result:= false;
  if SEndsWith(SInput, '%') then
  begin
    Num:= StrToIntDef(Copy(SInput, 1, Length(SInput)-1), -1);
    Result:= Num>=0;
    if Result then
      V.PosPercent:= Num;
  end
  else
  begin
    if SBeginsWith(SInput, 'x') then
      Num:= StrToInt64Def('$'+Copy(SInput, 2), -1)
    else
    if SBeginsWith(SInput, 'd') then
      Num:= StrToInt64Def(Copy(SInput, 2), -1)
    else
      Num:= StrToInt64Def(SInput, -1);
    Result:= Num>=0;
    if Result then
      V.PosAt(Num);
  end;
end;

procedure ApplyThemeToViewer(V: TATBinHex);
var
  St: TecSyntaxFormat;
begin
  V.Font.Name:= EditorOps.OpFontName;
  V.Font.Size:= EditorOps.OpFontSize;
  V.Font.Quality:= EditorOps.OpFontQuality;
  V.Font.Color:= GetAppColor(TAppThemeColor.EdTextFont);
  V.FontGutter.Name:= EditorOps.OpFontName;
  V.FontGutter.Size:= EditorOps.OpFontSize;
  V.FontGutter.Quality:= EditorOps.OpFontQuality;
  V.FontGutter.Color:= GetAppColor(TAppThemeColor.EdGutterFont);
  V.Color:= GetAppColor(TAppThemeColor.EdTextBg);
  V.TextColorGutter:= GetAppColor(TAppThemeColor.EdGutterBg);
  V.TextColorURL:= GetAppColor(TAppThemeColor.EdLinks);
  V.TextColorHi:= GetAppColor(TAppThemeColor.EdStateAdded);
  V.TextColorMarker:= GetAppColor(TAppThemeColor.EdMarkers);

  St:= GetAppStyle(TAppThemeStyle.SectionBG1);
  V.TextColorHexBack:= St.BgColor;

  St:= GetAppStyle(TAppThemeStyle.Id);
  V.TextColorHex:= St.Font.Color;

  St:= GetAppStyle(TAppThemeStyle.Id1);
  V.TextColorHex2:= St.Font.Color;

  St:= GetAppStyle(TAppThemeStyle.Comment);
  V.TextColorLines:= St.Font.Color;
end;


procedure ApplyThemeToImageBox(AImageBox: TATImageBox);
begin
  if Assigned(AImageBox) then
  begin
    AImageBox.Color:= GetAppColor(TAppThemeColor.EdTextBg);
  end;
end;

function AppStringToAlignment(const S: string): TAlignment;
begin
  case S of
    'L': Result:= taLeftJustify;
    'R': Result:= taRightJustify
     else Result:= taCenter;
  end;
end;

function AppAlignmentToString(const V: TAlignment): string;
begin
  case V of
    taLeftJustify: Result:= 'L';
    taRightJustify: Result:= 'R';
    else Result:= 'C';
  end;
end;

procedure DoPaintCheckers(C: TCanvas;
  ASizeX, ASizeY: integer;
  ACellSize: integer;
  AColor1, AColor2: TColor);
var
  i, j: integer;
begin
  c.Brush.Color:= AColor1;
  c.FillRect(0, 0, ASizeX, ASizeY);

  for i:= 0 to ASizeX div ACellSize + 1 do
    for j:= 0 to ASizeY div ACellSize + 1 do
      if odd(i) xor odd(j) then
      begin
        c.Brush.Color:= AColor2;
        c.FillRect(i*ACellSize, j*ACellSize, (i+1)*ACellSize, (j+1)*ACellSize);
      end;
end;

procedure MenuItem_Copy(ASrc, ADest: TMenuItem);
var
  mi: TMenuItem;
  i: integer;
begin
  ADest.Clear;
  ADest.Action:= ASrc.Action;
  ADest.AutoCheck:= ASrc.AutoCheck;
  ADest.Caption:= ASrc.Caption;
  ADest.Checked:= ASrc.Checked;
  ADest.Default:= ASrc.Default;
  ADest.Enabled:= ASrc.Enabled;
  ADest.Bitmap:= ASrc.Bitmap;
  ADest.GroupIndex:= ASrc.GroupIndex;
  ADest.GlyphShowMode:= ASrc.GlyphShowMode;
  ADest.HelpContext:= ASrc.HelpContext;
  ADest.Hint:= ASrc.Hint;
  ADest.ImageIndex:= ASrc.ImageIndex;
  ADest.RadioItem:= ASrc.RadioItem;
  ADest.RightJustify:= ASrc.RightJustify;
  ADest.ShortCut:= ASrc.ShortCut;
  ADest.ShortCutKey2:= ASrc.ShortCutKey2;
  ADest.ShowAlwaysCheckable:= ASrc.ShowAlwaysCheckable;
  ADest.SubMenuImages:= ASrc.SubMenuImages;
  //ADest.SubMenuImagesWidth:= ASrc.SubMenuImagesWidth; //needs Laz 1.9+
  ADest.Visible:= ASrc.Visible;
  ADest.OnClick:= ASrc.OnClick;
  ADest.OnDrawItem:= ASrc.OnDrawItem;
  ADest.OnMeasureItem:= ASrc.OnMeasureItem;
  ADest.Tag:= ASrc.Tag;

  for i:= 0 to ASrc.Count-1 do
  begin
    mi:= TMenuItem.Create(ASrc.Owner);
    MenuItem_Copy(ASrc.Items[i], mi);
    ADest.Add(mi);
  end;
end;

procedure Menu_Copy(ASrc, ADest: TMenu);
begin
  MenuItem_Copy(ASrc.Items, ADest.Items);
end;

function Menu_GetIndexToInsert(AMenu: TMenuItem; ACaption: string): integer;
var
  i: integer;
begin
  Result:= -1;
  ACaption:= StringReplace(ACaption, '&', '', [rfReplaceAll]);
  ACaption:= LowerCase(ACaption);

  for i:= 0 to AMenu.Count-1 do
    if LowerCase(AMenu.Items[i].Caption)>ACaption then
      exit(i);
end;


function LexerFilenameToComponentName(const fn: string): string;
var
  i: integer;
begin
  Result:= ChangeFileExt(ExtractFileName(fn), '');
  for i:= 1 to Length(Result) do
    if Pos(Result[i], ' ~!@#$%^&*()[]-+=;:.,')>0 then
      Result[i]:= '_';
end;


procedure DoFormFocus(F: TForm; AllowShow: boolean);
begin
  if Assigned(F) and F.Enabled then
  begin
    if not F.Visible then
      if AllowShow then
        F.Show
      else
        exit;
    F.SetFocus;

    {
    todo: make focusing of editor inside floating group
    }
  end;
end;

procedure FormHistoryLoad(F: TForm; const AConfigPath: string; AWithPos: boolean; const ADesktopRect: TRect);
var
  c: TAppJsonConfig;
  S: string;
begin
  c:= TAppJsonConfig.Create(nil);
  try
    try
      c.Filename:= AppFile_History;
    except
      exit;
    end;

    S:= c.GetValue(AConfigPath, '');
    if S<>'' then
      FormPosSetFromString(F, S, not AWithPos, ADesktopRect);
  finally
    c.Free;
  end;
end;

procedure FormHistorySave(F: TForm; const AConfigPath: string; AWithPos: boolean);
var
  c: TAppJsonConfig;
begin
  c:= TAppJsonConfig.Create(nil);
  try
    try
      c.Filename:= AppFile_History;
    except
      exit;
    end;

    c.SetValue(AConfigPath, FormPosGetAsString(F, not AWithPos));
  finally
    c.Free;
  end;
end;


procedure MenuShowAtEditorCorner(AMenu: TPopupMenu; Ed: TATSynEdit);
var
  P: TPoint;
begin
  P:= Ed.ClientToScreen(Point(0, 0));
  AMenu.Popup(P.X, P.Y);
end;

function StringToIntArray(const AText: string): TATIntArray;
var
  Sep: TATStringSeparator;
  N: integer;
begin
  SetLength(Result{%H-}, 0);
  Sep.Init(AText);
  repeat
    if not Sep.GetItemInt(N, 0) then Break;
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1]:= N;
  until false;
end;

function IntArrayToString(const A: TATIntArray): string;
var
  i: integer;
begin
  Result:= '';
  for i:= 0 to Length(A)-1 do
    Result+= IntToStr(A[i])+',';
  SetLength(Result, Length(Result)-1);
end;


function FinderOptionsToString(F: TATEditorFinder): string;
begin
  Result:= '';
  if F.OptBack then
    Result+= 'b';
  if F.OptCase then
    Result+= 'c';
  if F.OptRegex then
    Result+= 'r';
  if F.OptWords then
    Result+= 'w';
  if F.OptFromCaret then
    Result+= 'f';
  if F.OptInSelection then
    Result+= 's';
  if F.OptConfirmReplace then
    Result+= 'o';
  if F.OptWrapped then
    Result+= 'a';
  if F.OptWrappedConfirm then
    Result+= 'A';
  if F.OptPreserveCase then
    Result+= 'P';
  if F.OptTokens<>TATFinderTokensAllowed.All then
    Result+= 'T'+IntToStr(Ord(F.OptTokens));
end;

procedure FinderOptionsFromString(F: TATEditorFinder; const S: string);
var
  N: integer;
begin
  F.OptBack:= Pos('b', S)>0;
  F.OptCase:= Pos('c', S)>0;
  F.OptRegex:= Pos('r', S)>0;
  F.OptWords:= Pos('w', S)>0;
  F.OptFromCaret:= Pos('f', S)>0;
  F.OptInSelection:= Pos('s', S)>0;
  F.OptConfirmReplace:= Pos('o', S)>0;
  F.OptWrapped:= Pos('a', S)>0;
  F.OptWrappedConfirm:= Pos('A', S)>0;
  F.OptPreserveCase:= Pos('P', S)>0;
  F.OptTokens:= TATFinderTokensAllowed.All;

  N:= Pos('T', S);
  if (N>0) and (N<Length(S)) then
  begin
    N:= StrToIntDef(S[N+1], 0);
    F.OptTokens:= TATFinderTokensAllowed(N);
  end;
end;

function FormatFilenameForMenu(const fn: string): string;
begin
  Result:= ExtractFileName(fn)+' ('+ExtractFileDir(fn)+')';
end;

procedure AppScaleSplitter(C: TSplitter);
var
  NSize: integer;
begin
  NSize:= ATEditorScale(4);
  if C.Align in [alLeft, alRight] then
    C.Width:= NSize
  else
    C.Height:= NSize;
end;

function AppNicePluginCaption(const S: string): string;
begin
  Result:= S;
  Result:= StringReplace(Result, '\', ': ', [rfReplaceAll]);
  Result:= StringReplace(Result, '&', '', [rfReplaceAll]);
end;

function FormPosGetAsString(Form: TForm; AOnlySize: boolean): string;
var
  X, Y, W, H: integer;
begin
  if AOnlySize then
  begin
    X:= 0;
    Y:= 0;
  end
  else
  begin
    X:= Form.Left;
    Y:= Form.Top;
  end;
  W:= Form.Width;
  H:= Form.Height;

  Result:= Format('%d,%d,%d,%d', [X, Y, W, H]);
end;

procedure RectSetFromString(var R: TRect; const S: string; AOnlySize: boolean; const ADesktopRect: TRect);
var
  Sep: TATStringSeparator;
  X, Y, W, H: integer;
begin
  if S='' then exit;
  Sep.Init(S);
  Sep.GetItemInt(X, R.Left);
  Sep.GetItemInt(Y, R.Top);
  Sep.GetItemInt(W, R.Width);
  Sep.GetItemInt(H, R.Height);

  //prevert LCL exceptions when numbers are too big, CudaText issue #3626
  X:= Min(X, ADesktopRect.Right-50);
  Y:= Min(Y, ADesktopRect.Bottom-50);
  W:= Min(W, ADesktopRect.Width);
  H:= Min(H, ADesktopRect.Height);

  if not AOnlySize then
  begin
    R.Left:= X;
    R.Top:= Y;
  end;

  R.Right:= R.Left+W;
  R.Bottom:= R.Top+H;
end;


procedure FormPosSetFromString(Form: TForm; const S: string; AOnlySize: boolean; const ADesktopRect: TRect);
var
  R: TRect;
begin
  R:= Form.BoundsRect;
  RectSetFromString(R, S, AOnlySize, ADesktopRect);
  if Form.BoundsRect<>R then
    Form.BoundsRect:= R;
end;

procedure FormLock(Ctl: TForm);
begin
  Ctl.DisableAutoSizing;

  {$ifdef windows}
  Ctl.Perform(WM_SetRedraw, 0, 0);
  {$endif}
end;

procedure FormUnlock(Ctl: TForm);
begin
  Ctl.EnableAutoSizing;

  {$ifdef windows}
  Ctl.Perform(WM_SetRedraw, 1, 0);
  SetWindowPos(Ctl.Handle, 0, 0, 0, 0, 0,
    SWP_FRAMECHANGED or SWP_NOCOPYBITS or SWP_NOMOVE or SWP_NOZORDER or SWP_NOSIZE);
  {$endif}
end;

{
procedure ControlAutosizeOnlyByWidth(C: TWinControl);
var
  N, i: integer;
begin
  N:= 0;
  for i:= 0 to C.ControlCount-1 do
    if C.Controls[i].Visible then
      Inc(N, C.Controls[i].Width);
  C.Width:= N;
end;
}

function Canvas_TextMultilineExtent(C: TCanvas; const AText: string): TPoint;
var
  Sep: TATStringSeparator;
  SItem: string;
  Ext: Types.TSize;
begin
  Result.X:= 0;
  Result.Y:= 0;
  Sep.Init(AText, #10);
  while Sep.GetItemStr(SItem) do
  begin
    Ext:= C.TextExtent(SItem);
    Inc(Result.Y, Ext.cy);
    Result.X:= Max(Result.X, Ext.cx);
  end;
end;

{ TAppSplitter }

procedure TAppSplitter.Paint;
var
  C: TCanvas;
begin
  if CustomColored then
  begin
    C:= Canvas;
    C.Brush.Color:= Self.Color;
    C.FillRect(0, 0, Width, Height);
  end
  else
    inherited Paint;
end;

{ TAppPanelEx }

constructor TAppPanelEx.Create(TheOwner: TComponent);
begin
  inherited;
  BevelInner:= bvNone;
  BevelOuter:= bvNone;
  BorderStyle:= bsNone;
  Color:= clYellow;
  ColorFrame:= clRed;
  PaddingX:= 1;
  PaddingY:= 1;
end;

procedure TAppPanelEx.Paint;
var
  C: TCanvas;
  R: TRect;
  Sep: TATStringSeparator;
  SItem: string;
  H, NX, NY: integer;
begin
  R:= ClientRect;
  C:= Canvas;
  C.Brush.Color:= Color;
  C.Pen.Color:= ColorFrame;
  C.Rectangle(R);
  C.Font.Assign(Self.Font);
  InflateRect(R, -1, -1);

  NX:= PaddingX;
  NY:= PaddingY;
  H:= C.TextHeight('Wj');

  Sep.Init(Caption, #10);
  while Sep.GetItemStr(SItem) do
  begin
    C.TextOut(NX, NY, SItem);
    Inc(NY, H);
  end;
end;

function AppGetLeveledPath(const AFileName: string; ALevel: integer): string;
var
  N, i: integer;
begin
  Result:= '';
  if AFileName='' then exit;
  N:= Length(AFileName)+1;
  for i:= 0 to ALevel do
  begin
    N:= RPosEx(DirectorySeparator, AFileName, N-1);
    if N<=0 then
      Break;
  end;
  Result:= Copy(AFileName, N+1, MaxInt);
end;

procedure AppListbox_CopyOneLine(L: TATListbox);
begin
  if L.IsIndexValid(L.ItemIndex) then
    SClipboardCopy(L.Items[L.ItemIndex]);
end;

procedure AppListbox_CopyAllLines(L: TATListbox);
begin
  SClipboardCopy(L.Items.Text);
end;

procedure AppListbox_Clear(L: TATListbox);
begin
  L.Items.Clear;
  L.ItemIndex:= -1;
  L.ItemTop:= 0;
  L.Invalidate;
end;

function IsStringArrayWithSubstring(const Ar: array of string; const AText: string): boolean;
var
  i: integer;
begin
  Result:= false;
  for i:= 0 to High(Ar) do
    if Pos(AText, Ar[i])>0 then
      exit(true);
end;

function MultiSelectStyleToString(St: TMultiSelectStyle): string;
begin
  Result:= '';
  if msControlSelect in St then
    Result+= 'c';
  if msShiftSelect in St then
    Result+= 's';
  if msVisibleOnly in St then
    Result+= 'v';
  if msSiblingOnly in St then
    Result+= 'i';
end;

function StringToMultiSelectStyle(const S: string): TMultiSelectStyle;
begin
  Result:= [];
  if Pos('c', S)>0 then Include(Result, msControlSelect);
  if Pos('s', S)>0 then Include(Result, msShiftSelect);
  if Pos('v', S)>0 then Include(Result, msVisibleOnly);
  if Pos('i', S)>0 then Include(Result, msSiblingOnly);
end;

procedure InitHtmlTags;
begin
  if Assigned(HtmlTags) then exit;
  HtmlTags:= TStringList.Create;
  HtmlTags.UseLocale:= false;
  HtmlTags.Sorted:= true;
  HtmlTags.Add('a');
  HtmlTags.Add('abbr');
  HtmlTags.Add('acronym');
  HtmlTags.Add('address');
  HtmlTags.Add('applet');
  HtmlTags.Add('article');
  HtmlTags.Add('aside');
  HtmlTags.Add('audio');
  HtmlTags.Add('b');
  HtmlTags.Add('basefont');
  HtmlTags.Add('bdi');
  HtmlTags.Add('bdo');
  HtmlTags.Add('big');
  HtmlTags.Add('blockquote');
  HtmlTags.Add('body');
  HtmlTags.Add('button');
  HtmlTags.Add('canvas');
  HtmlTags.Add('caption');
  HtmlTags.Add('center');
  HtmlTags.Add('cite');
  HtmlTags.Add('code');
  HtmlTags.Add('colgroup');
  HtmlTags.Add('data');
  HtmlTags.Add('datalist');
  HtmlTags.Add('dd');
  HtmlTags.Add('del');
  HtmlTags.Add('details');
  HtmlTags.Add('dfn');
  HtmlTags.Add('dialog');
  HtmlTags.Add('dir');
  HtmlTags.Add('div');
  HtmlTags.Add('dl');
  HtmlTags.Add('dt');
  HtmlTags.Add('em');
  HtmlTags.Add('fieldset');
  HtmlTags.Add('figcaption');
  HtmlTags.Add('figure');
  HtmlTags.Add('font');
  HtmlTags.Add('footer');
  HtmlTags.Add('form');
  HtmlTags.Add('frame');
  HtmlTags.Add('frameset');
  HtmlTags.Add('h1 to h6');
  HtmlTags.Add('head');
  HtmlTags.Add('header');
  HtmlTags.Add('html');
  HtmlTags.Add('i');
  HtmlTags.Add('iframe');
  HtmlTags.Add('ins');
  HtmlTags.Add('kbd');
  HtmlTags.Add('label');
  HtmlTags.Add('legend');
  HtmlTags.Add('li');
  HtmlTags.Add('main');
  HtmlTags.Add('map');
  HtmlTags.Add('mark');
  HtmlTags.Add('meter');
  HtmlTags.Add('nav');
  HtmlTags.Add('noframes');
  HtmlTags.Add('noscript');
  HtmlTags.Add('object');
  HtmlTags.Add('ol');
  HtmlTags.Add('optgroup');
  HtmlTags.Add('option');
  HtmlTags.Add('output');
  HtmlTags.Add('p');
  HtmlTags.Add('picture');
  HtmlTags.Add('pre');
  HtmlTags.Add('progress');
  HtmlTags.Add('q');
  HtmlTags.Add('rp');
  HtmlTags.Add('rt');
  HtmlTags.Add('ruby');
  HtmlTags.Add('s');
  HtmlTags.Add('samp');
  HtmlTags.Add('script');
  HtmlTags.Add('section');
  HtmlTags.Add('select');
  HtmlTags.Add('small');
  HtmlTags.Add('span');
  HtmlTags.Add('strike');
  HtmlTags.Add('strong');
  HtmlTags.Add('style');
  HtmlTags.Add('sub');
  HtmlTags.Add('summary');
  HtmlTags.Add('sup');
  HtmlTags.Add('svg');
  HtmlTags.Add('table');
  HtmlTags.Add('tbody');
  HtmlTags.Add('td');
  HtmlTags.Add('template');
  HtmlTags.Add('textarea');
  HtmlTags.Add('tfoot');
  HtmlTags.Add('th');
  HtmlTags.Add('thead');
  HtmlTags.Add('time');
  HtmlTags.Add('title');
  HtmlTags.Add('tr');
  HtmlTags.Add('tt');
  HtmlTags.Add('u');
  HtmlTags.Add('ul');
  HtmlTags.Add('var');
  HtmlTags.Add('video');
end;


procedure AppInitProgressForm(out AForm: TForm; out AProgress: TATGauge;
  out AButtonCancel: TATButton; const AText: string);
const
  cIndent = 6;
  cBtnHeight = 20;
  cBtnWidth = 80;
var
  Pane, Pane2: TPanel;
begin
  AForm:= TForm.CreateNew(nil, 0);
  AForm.Width:= 600;
  AForm.Height:= 60;
  AForm.Caption:= 'CudaText';
  AForm.FormStyle:= fsStayOnTop;
  AForm.Position:= poScreenCenter;
  AForm.BorderStyle:= bsDialog;
  AForm.Color:= GetAppColor(TAppThemeColor.TabBg);

  Pane:= TPanel.Create(AForm);
  Pane.Align:= alClient;
  Pane.Parent:= AForm;
  Pane.BevelInner:= bvNone;
  Pane.BevelOuter:= bvNone;
  Pane.Font.Name:= UiOps.VarFontName;
  Pane.Font.Size:= UiOps.VarFontSize;
  Pane.Font.Color:= GetAppColor(TAppThemeColor.TabFont);
  Pane.Caption:= AText;

  Pane2:= TPanel.Create(AForm);
  Pane2.Align:= alBottom;
  Pane2.Height:= cBtnHeight+cIndent*2;
  Pane2.Parent:= AForm;
  Pane2.BevelInner:= bvNone;
  Pane2.BevelOuter:= bvNone;
  Pane2.Caption:= '';

  AProgress:= TATGauge.Create(AForm);
  AProgress.Align:= alClient;
  AProgress.Parent:= Pane2;
  AProgress.Kind:= gkHorizontalBar;
  AProgress.ShowText:= false;
  AProgress.BorderSpacing.Bottom:= cIndent;
  AProgress.BorderSpacing.Left:= cIndent;
  AProgress.BorderSpacing.Right:= cIndent;
  AProgress.Progress:= 0;

  AButtonCancel:= TATButton.Create(AForm);
  AButtonCancel.Align:= alRight;
  AButtonCancel.Parent:= Pane2;
  AButtonCancel.Width:= cBtnWidth;
  AButtonCancel.BorderSpacing.Bottom:= cIndent;
  AButtonCancel.BorderSpacing.Left:= cIndent;
  AButtonCancel.BorderSpacing.Right:= cIndent;
end;


procedure StringsDeduplicate(L: TStringList; CaseSens: boolean);
var
  i, j: integer;
  equal: boolean;
begin
  for i:= L.Count-1 downto 1{>0} do
    for j:= i-1 downto 0 do
    begin
      if CaseSens then
        equal:= L[i]=L[j]
      else
        equal:= CompareText(L[i], L[j])=0;
      if equal then
      begin
        L.Delete(i);
        Break;
      end;
    end;
end;


function AppValidateJson(const AText: string): boolean;
var
  fn: string;
  cfg: TAppJsonConfig;
begin
  fn:= GetTempDir(false)+'cudatext_validation.json';
  if FileExists(fn) then
    DeleteFile(fn);
  DoWriteStringToFile(fn, AText);

  cfg:= TAppJsonConfig.Create(nil);
  try
    try
      cfg.Filename:= fn;
      Result:= true;
    except
      on E: Exception do
      begin
        MsgBox('Incorrect JSON:'#10+E.Message, MB_OK+MB_ICONERROR);
        Result:= false;
      end;
    end;
  finally
    FreeAndNil(cfg);
    DeleteFile(fn);
  end;
end;

procedure FormPutToVisibleArea(F: TForm);
var
  R: TRect;
begin
  R:= Screen.DesktopRect;

  if F.Width>R.Width then
    F.Width:= R.Width-2;
  if F.Height>R.Height then
    F.Height:= R.Height-2;

  F.Left:= Max(R.Left, Min(R.Right-F.Width, F.Left));
  F.Top:= Max(R.Top, Min(R.Bottom-F.Height, F.Top));
end;

function StringsTrailingText(L: TStringList; AItemCount: integer): string;
var
  i: integer;
begin
  Result:= '';
  for i:= Max(0, L.Count-AItemCount) to L.Count-1 do
  begin
    Result+= L[i];
    if i<L.Count-1 then
      Result+= #10;
  end;
end;

function ConvertCssColorToTColor(const S: string): TColor;
var
  NLen, i: integer;
begin
  Result:= clNone;
  if Length(S)<4 then exit;

  i:= 1;
  case S[i] of
    '#':
      begin
        //find #rgb, #rrggbb
        if IsCharHexDigit(S[i+1]) then
        begin
          Result:= TATHtmlColorParserA.ParseTokenRGB(@S[i+1], NLen, clNone);
          Inc(NLen);
        end;
      end;
    'r':
      begin
        //find rgb(...), rgba(...)
        if (S[i+1]='g') and
          (S[i+2]='b') and
          ((i=1) or not IsCharWord(S[i-1], ATEditorOptions.DefaultNonWordChars)) //word boundary
        then
        begin
          Result:= TATHtmlColorParserA.ParseFunctionRGB(S, i, NLen);
          //bFoundBrackets:= true;
        end;
      end;
    'h':
      begin
        //find hsl(...), hsla(...)
        if (S[i+1]='s') and
          (S[i+2]='l') and
          ((i=1) or not IsCharWord(S[i-1], ATEditorOptions.DefaultNonWordChars)) //word boundary
        then
        begin
          Result:= TATHtmlColorParserA.ParseFunctionHSL(S, i, NLen);
          //bFoundBrackets:= true;
        end;
      end;
  end;
end;


{ TAppCodetreeSavedFold }

procedure TAppCodetreeSavedFold.Save(Ed: TATSynEdit; ATree: TTreeView);
var
  Node: TTreeNode;
begin
  Cap:= '';
  Cap2:= '';
  if Ed.Carets.Count>0 then
  begin
    Node:= CodetreeFindItemForPosition(ATree, Ed.Carets[0].PosX, Ed.Carets[0].PosY);
    if Assigned(Node) then
    begin
      Cap:= Node.Text;
      if Assigned(Node.Parent) then
        Cap2:= Node.Parent.Text;
    end;
  end;
end;

procedure TAppCodetreeSavedFold.Restore(Ed: TATSynEdit; ATree: TTreeView);
var
  Node: TTreeNode;
begin
  if (Cap<>'') or (Cap2<>'') then
    if (Ed.Carets.Count>0) then
    begin
      Node:= CodetreeFindItemForPosition(ATree, Ed.Carets[0].PosX, Ed.Carets[0].PosY);
      if Assigned(Node) then
        if (Cap=Node.Text) or (Cap2=Node.Text) then
          Node.Expand(false);
    end;
end;


function AppCountCommandlineFilenames(const Ar: array of string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to High(Ar) do
    if not SBeginsWith(Ar[i], '-') then
      Inc(Result);
end;

function IsPointsDiffByDelta(const P1, P2: TPoint; Delta: integer): boolean;
begin
  Result:=
    (Abs(P1.X-P2.X)>=Delta) or
    (Abs(P1.Y-P2.Y)>=Delta);
end;

finalization

  if Assigned(HtmlTags) then
    FreeAndNil(HtmlTags);

end.

