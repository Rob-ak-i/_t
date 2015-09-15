uses
	GraphABC, ABCObjects, ABCSprites, Timers, System.Net;
Const
	NetSprite : String = 'picture.jpg';
	Type
	TControlledUnit = class
		selected		: Boolean;
		Side			: Word;
		procedure		Select;
		procedure		UnSelect;
	end;
		procedure		TControlledUnit.Select;begin Selected:=True;end;
		procedure		TControlledUnit.UnSelect;begin Selected:=False;end;
Type
	TTank				= class(TControlledUnit)
	private
		Picture1		: GraphABC.Picture;
		X,Y,
		X1,Y1			: integer;
		backX,backY		: integer;
		angle,neededangle	: real;
		orient			: boolean;
		side			: integer;
		issingle		: boolean;
		model			: string;
		moving,
		rotating		: boolean;
		cX, cY, errX, errY, d, dx, dy, incX, incY, num: integer;
		turretturnrate	: real;
		StopIfEnd	: boolean;
	public
		constructor		create(model1 : string;issingle1 : boolean;num1 : integer;X11,Y11 : integer;Owner : Word);
		procedure		SetSpeed(speed11 : integer);
		procedure		Draw;
		procedure		Update;
		procedure		MoveTo(X11, Y11 : Word;StopIfEnd1 : Boolean);
	end;
    
		constructor		TTank.create(model1 : string;issingle1 : boolean;num1:integer;X11,Y11 : integer;Owner : Word);
			begin
				Side:= Owner;
				model:=model1;
				issingle:=issingle1;
				num:=num1;
				turretturnrate:=4;
				moving:=false;rotating:=false;
				X:=X11;Y:=Y11;
				BackX:=X;BackY:=Y;
				Picture1:=GraphABC.Picture.Create(model);
				Picture1.Transparent	:= True;
				Picture1.TransparentColor	:= Color.FromArgb($FFFFFFFF);
			end;
		procedure		TTank.SetSpeed(speed11 : integer);begin num:=Speed11; end;
		procedure		TTank.Draw;
			begin
				Picture1.Draw(X-16,Y-16,angle,32,32);
				BackX:=X;
				BackY:=Y;
			end;
		procedure		TTank.update;
		var a,b : real;
			begin
				if rotating then begin
					a:=neededangle-turretturnrate-1;
					b:=neededangle+turretturnrate+1;
					{if a<0 then a:=a+360 else
						if a>=360 then a:=a-360;
					if b<0 then b:=b+360 else
						if b>=360 then b:=b-360;}
					for var i:=1 to 3 do
						if((angle<a)or(angle>b)) then begin
							if(orient)
							then angle:=angle-turretturnrate
							else angle:=angle+turretturnrate;
							if (angle<0) then angle:=angle+360 else
								if (angle>=360) then angle:=angle-360;
						end else begin
							angle:=neededangle;
							rotating:=false;
							exit;
						end;
				end else
				if moving then begin
					for var i:=1 to num do
						if((cX <> X1) OR (cY <> Y1)or not(StopIfEnd))then begin
							Inc(errX,dx);
							Inc(errY,dy);
							if(errX >= d) then begin
								Dec(errX,d);
								Inc(cX,incX);
							end;
							if(errY >= d) then begin
								Dec(errY,d);
								Inc(cY,incY);
							end;
							X:=CX;
							Y:=CY;
						end else moving:=false;
				end;
			end;
		procedure		TTank.MoveTo(X11, Y11 : Word;StopIfEnd1 : Boolean);
			begin
				x1:=x11;y1:=y11;
				dx:=x1-x;dy:=y1-y;errX:=0;errY:=0;
				if (dx<>0)then neededangle:= arccos(dx/sqrt(sqr(dx)+sqr(dy)));
				if(dx=0)then neededangle:=pi/2;
				if(dy<0)then neededangle:=180*(2-neededangle/pi);
				if(dy>=0)then neededangle:=neededangle*180/pi;
				if(angle<>neededangle)then begin
					//if (neededangle-angle)>180 then  
					orient:=not(180<(angle-neededangle))and((0<(angle-neededangle))or(-180>(angle-neededangle)));
					rotating:=true;
				end;
				var str:=concat(angle.ToString,';',neededangle.tostring);
				setwindowtitle(str);
				incX:=Sign(dx);incY:=Sign(dy);dx := Abs(dx);dy := Abs(dy);
				if(dy > dx) then d := dy else d := dx; {///} cX := x; cY := y;
				StopIfEnd:=StopIfEnd1;
				moving:=true;
			end;
Type
	TSide	= Record
		Selected : Word := -1;
	End;
var
	W				: System.Net.WebClient := System.Net.WebClient.Create();
	PictureScr,PictureSelector		: GraphABC.Picture;
	//Owner				: Word;
	UpdateTimer,	GrafixTimer,LoadingTimer		: Timer;
	MausDown		: Boolean := False;
	numberofunits	: Word :=3;
	speed1			: integer := 2;
	Sides				: Array[1..2]of TSide;
	Tank				: array[0..3] of TTank;
	//socket1			: sockets.socket
	Multiplayer	: Boolean;

	procedure	move1	(selectedunit		: integer;
						dx, dy		: integer);
		begin
			if(selectedunit>=0)and(selectedunit<=3)then
			tank[selectedunit].MoveTo(tank[selectedunit].X+dx, tank[selectedunit].Y+dy,False);
		end;
	{procedure OpenConnection;
		begin			
		end;}
	Procedure	ScreenDraw;
		//var
			//truue : boolean;
		begin
			for var i:=0 to 31 do 
				for var j:=0 to 15 do
					PictureScr.Draw(i*32,j*32);
			//truue:=(Selected>=0)and(Selected<=3);
			for var i:=0 to 3 do begin
				if(Sides[1].Selected=i)
				then PictureSelector.Draw(Tank[Sides[1].Selected].X-18,Tank[Sides[1].Selected].Y-18);
				Tank[i].Draw;
			end;
				redraw;
		end;
	procedure Update;
		begin
			for var i:=0 to 3 do begin
				Tank[i].Update;
			end;
		end;
	procedure UpdateMP;
		begin
			for var i:=0 to 3 do begin
				Tank[i].Update;
			end;
		end;
	procedure MouseDown(x,y,mousebutton: integer);
		begin
			MausDown:=True;
		end;
	procedure MouseUp(x,y,mousebutton: integer);
		begin
			if not MausDown then exit;
			MausDown:=False;
			{if (selected>=0)and(selected<=3)then }
			If(Sides[1].selected>-1)and(Sides[1].Selected<=numberofunits) then
				tank[Sides[1].selected].MoveTo(X,Y,True);
		end;
	procedure selector(Number : Integer;Owner : Integer);
		begin
			if ((owner<1)and(owner>2)) then exit;
			if ((number>-1)and(number<=numberofunits)) then begin
				if Tank[Number].side = Owner then Sides[Owner].selected:=Number;
			end else Sides[Owner].selected:=-1;
		end;
	procedure	KeyDown(key : integer);
		begin
			Case key of
				VK_Escape		: CloseWindow;
				VK_S			: move1(Sides[1].Selected,0,speed1);
				VK_W			: move1(Sides[1].Selected,0,-speed1);
				VK_D			: move1(Sides[1].Selected,speed1,0);
				VK_A			: move1(Sides[1].Selected,-speed1,0);
			end;
		end;
	procedure	KeyUp(key : integer);
		begin
			Case key of
				VK_Escape		: CloseWindow;
				VK_S,
				VK_W,
				VK_D,
				VK_A			: {if((Selected>=0)and(Selected<=3))then}  tank[Sides[1].Selected].moving:=False;
				VK_Q			: if(speed1>-2)then begin Dec(speed1); end;
				VK_E			: if(speed1<10)then begin Inc(speed1); end;
				VK_NumPad0: selector(-1,1);
				VK_NumPad1: selector(0,1);
				VK_NumPad2: selector(1,1);
				VK_NumPad3: selector(2,1);
				VK_NumPad4: selector(3,1);
			end;
		end;
	procedure GamePrepare;
		begin
			GraphABC.OnKeyDown		:= KeyDown;
			GraphABC.OnKeyUp			:= KeyUp;
			GraphABC.OnMouseDown	:= MouseDown;
			GraphABC.OnMouseUp		:= MouseUp;
			SetWindowTitle('_t5');
			if Multiplayer then 
				UpdateTimer := new Timer(60, Update)
			else
				UpdateTimer := new Timer(60, UpdateMP);
			UpdateTimer.Start;
			GrafixTimer := new Timer(60, ScreenDraw);
			GrafixTimer.Start;
			LoadingTimer.Stop;
			PictureSelector.Transparent	:= True;
			PictureSelector.TransparentColor	:= Color.FromArgb($FFFFFFFF);
		end;
	procedure Loading;
		var str1:string;Control : boolean;
		begin
			SetWindowWidth(1);
			SetWindowHeight(1);
			var R : System.Windows.Forms.DialogResult := 
			System.Windows.Forms.MessageBox.Show('Multiplayer 2 - Yes,Multiplayer 1 - No, Singleplayer - Cancel',
			'Multiplayer?', System.Windows.Forms.MessageBoxButtons.YesNoCancel, System.Windows.Forms.MessageBoxIcon.Information);
			{Multiplayer := R.HasFlag(System.Windows.Forms.DialogResult.Yes);}
			//MessageBoxManager.Unregister();
			Multiplayer := not (R=System.Windows.Forms.DialogResult.Cancel);
			Control := not (R=System.Windows.Forms.DialogResult.Yes);
			SetWindowTitle(Multiplayer.ToString);
			W.DownloadFile('https://yandex.ru/images/today?size=512x1024',NetSprite);
			SetWindowWidth(1024);
			SetWindowHeight(512);
			GraphABC.FillWindow(NetSprite);
			GraphABC.LockDrawing;
			if Control then begin
				for var i:=0 to 2 do begin
					str1:=concat('tex\tank',i.ToString,'.bmp');
					Tank[i] := TTank.Create(str1,false,2,16,32*(i+1),1);
				end;
				str1:=concat('tex\tank3.bmp');
				Tank[3] := TTank.Create(str1,false,2,16,32*(4),2);
				PictureScr	:= Picture.Create('tex\terrain1.bmp');
				PictureSelector := Picture.Create('tex\selector.bmp');
			end else begin
				for var i:=0 to 2 do begin
					str1:=concat('tex\tank',i.ToString,'.bmp');
					Tank[i] := TTank.Create(str1,false,2,16,32*(i+1),2);
				end;
				str1:=concat('tex\tank3.bmp');
				Tank[3] := TTank.Create(str1,false,2,16,32*(4),1);
				PictureScr	:= Picture.Create('tex\terrain2.bmp');
				PictureSelector := Picture.Create('tex\selector2.bmp');
			end;
			LoadingTimer := new Timer(3000, GamePrepare);
			LoadingTimer.Start;
			
		end;
begin
	
	Loading;
end.