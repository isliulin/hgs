unit UnitWinFireWallManage2;

interface

uses
  SysUtils, ActiveX, ComObj, Variants,
  NetFwTypeLib_TLB;

//const
//  NET_FW_PROFILE2_PRIVATE = 2;
//  NET_FW_PROFILE2_PUBLIC  = 4;
//  NET_FW_PROFILE2_DOMAIN  = 1;
//  NET_FW_IP_PROTOCOL_TCP = 6;
//  NET_FW_ACTION_ALLOW    = 1;
//  NET_FW_RULE_DIR_IN  = 1;
//  NET_FW_RULE_DIR_OUT = 2;
//  NET_FW_IP_VERSION_V4 = 0;

procedure DoAddExceptionToFirewall(Const Caption, Executable: String;Port : Word);
procedure DoRemoveExceptFromFirewall(const RuleName: String);
function DoIsTCPPortAllowed(p_nPort: Integer; p_sAddress: string): Boolean;
procedure GetRulesFromFirewall(Const Caption: String);

implementation

procedure AddExceptionToFirewall(Const Caption, Executable: String;Port : Word);
var
  fwPolicy2      : OleVariant;
  RulesObject    : OleVariant;
  Profile        : Integer;
  NewRule        : OleVariant;
begin
  Profile             := NET_FW_PROFILE2_ALL;
  fwPolicy2           := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject         := fwPolicy2.Rules;
  NewRule             := CreateOleObject('HNetCfg.FWRule');
  NewRule.Name        := Caption;
  NewRule.Description := Caption;
  NewRule.Applicationname := Executable;
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts :=  Port;
  NewRule.Direction := NET_FW_RULE_DIR_IN;
  NewRule.Enabled := TRUE;
  NewRule.Grouping := 'HiTEMS';
  NewRule.Profiles := Profile;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  RulesObject.Add(NewRule);
end;

procedure GetRulesFromFirewall(Const Caption: String);
var
  fwPolicy2      : INetFwPolicy2;
  RulesObject    : INetFwRules;
  Profile        : Integer;
  NewRule        : INetFwRule;
begin
  Profile             := NET_FW_PROFILE2_ALL;
  fwPolicy2           := INetFwPolicy2(CreateOleObject('HNetCfg.FwPolicy2'));
  RulesObject         := fwPolicy2.Rules;
  NewRule := RulesObject.Item(Caption);

  if Assigned(NewRule) then
  begin
    NewRule.Profiles := Profile;
  end;
end;

procedure RemoveExceptFromFirewall(const RuleName: String);
var
  Profile: Integer;
  Policy2: OleVariant;
  RObject: OleVariant;
begin
  Profile := NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC;
  Policy2 := CreateOleObject('HNetCfg.FwPolicy2');
  RObject := Policy2.Rules;
  RObject.Remove(RuleName);
end;

function IsTCPPortAllowed(p_nPort: Integer; p_sAddress: string): Boolean;
var
  bAllowed, bRestricted: OleVariant;
  oFwMgr               : OleVariant;
  oResult              : HRESULT;
begin
  bAllowed    := False;
  bRestricted := False;
  Result      := False;

  CoInitialize(nil);
  try
    oFwMgr  := CreateOLEObject('HNetCfg.FwMgr');
    oResult := oFwMgr.IsPortAllowed('', NET_FW_IP_VERSION_V4, p_nPort, p_sAddress, NET_FW_IP_PROTOCOL_TCP, bAllowed, bRestricted);
    if oResult = S_OK then
      Result := bAllowed and not bRestricted;
  finally
    oFwMgr    := VarNull;
    CoUninitialize;
  end;
end;

procedure DoAddExceptionToFirewall(Const Caption, Executable: String;Port : Word);
begin
  try
    CoInitialize(nil);
    try
      AddExceptionToFirewall(Caption, Executable, Port);
//      AddExceptionToFirewall('MyAppRule','MyApp.exe', 3307);
    finally
      CoUninitialize;
    end;
  except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
  end;
end;

procedure DoRemoveExceptFromFirewall(const RuleName: String);
begin
  try
    CoInitialize(nil);
    try
      RemoveExceptFromFirewall(RuleName);
//      AddExceptionToFirewall('MyAppRule','MyApp.exe', 3307);
    finally
      CoUninitialize;
    end;
  except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
  end;
end;

function DoIsTCPPortAllowed(p_nPort: Integer; p_sAddress: string): Boolean;
begin
  Result := IsTCPPortAllowed(p_nPort, p_sAddress);
end;

end.
