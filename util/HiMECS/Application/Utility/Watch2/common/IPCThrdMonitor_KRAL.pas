unit IPCThrdMonitor_KRAL;
{
  IPCThrdMonitor Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, Classes, SysUtils, IPCThrd_KRAL;//, IPCThrdConst;

Type
{ TIPCMonitor_FlowMeter }

  TIPCMonitor_KRAL = class(TIPCThread_KRAL)
  protected
    procedure DoOnSignal;
    procedure Execute; override;
  public
    constructor Create(AID: Integer; const AName: string; AManual: Boolean);
  end;

implementation

{ TIPCMonitor_KRAL }

constructor TIPCMonitor_KRAL.Create(AID: Integer; const AName: string; AManual: Boolean);
begin
  inherited Create(AID, AName, AManual);
end;

procedure TIPCMonitor_KRAL.Execute;
var
  WaitResult: Integer;
begin
  DbgStr(FName + ' Activated');
  while not Terminated do
  try
    WaitResult := WaitForSingleObject(FMonitorEvent.Handle, INFINITE);
    if WaitResult = WAIT_OBJECT_0 then          { Monitor Event }
    begin
      case FMonitorEvent.Kind of
        evClientSignal: //Client�� ���� ���� Signal�� ����
          DoOnSignal;
      end;
    end
    else
      DbgStr(Format('Unexpected Wait Return Code: %d', [WaitResult]));
  except
    on E:Exception do
      DbgStr(Format('Exception raised in Thread Handler: %s at %X', [E.Message, ExceptAddr]));
  end;
  DbgStr('Thread Handler Exited');
end;

{ This method is called when the client has new data for us }

procedure TIPCMonitor_KRAL.DoOnSignal;
begin
  if Assigned(FOnSignal) then//and (FMonitorEvent.ID = FClientID) then
    FOnSignal(Self, FMonitorEvent.Data);
end;

end.