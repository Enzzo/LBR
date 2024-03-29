//+------------------------------------------------------------------+
//|                                                    LotByRisk.mq4 |
//|                                                           Sergey |
//|                             https://www.mql5.com/ru/users/enzzo/ |
//+---------------------------------------------------------------------------------+
//| Советник выставляет сделку нажатии на кнопку TR (trade)                         |
//| Cтоплос должен быть заданы обязательно                                          |
//| Направление сделки определяется положением стоплоса                             |
//| Риск рассчитывается от свободной маржи                                          |
//+---------------------------------------------------------------------------------+
//| |
//| |
//| |
//| |
//+---------------------------------------------------------------------------------+
#property copyright "Sergey"
#property link      "https://www.mql5.com/ru/users/enzzo/"
#property version   "1.00"

#property description "The Lot by Risk trading panel is designed for manual trading."
#property description "This is an alternative means for sending orders."
#property description "The first feature of the panel is convenient placing of orders using control lines."
#property description "The second feature is the calculation of the order volume for a given risk and the presence of a stop loss line."

#include <Trade.mqh>

CTrade trade;


input int         MAGIC    = 111087;   //magic
input string	  RISK	   = "%";	   //risk
input int         SLIPPAGE = 5;        //slippage
input string      COMMENT  = "";       //comment
input int         FNT      = 7;        //font
input string      HK_TP    = "T";      //hotkey for TP
input string      HK_SL    = "S";      //hotkey for SL
input string      HK_PR    = "P";      //hotkey for PRICE

string pref = "LBR";

string t_line = pref + "_t_line";
string s_line = pref + "_s_line";
string p_line = pref + "_p_line";

int mtp = 1;

string fName = Symbol()+WindowExpertName()+".csv";
int OnInit(){
//---
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   trade.SetExpertMagic(MAGIC);
   trade.SetExpertComment(COMMENT);
   
   if(Digits() == 5 || Digits() == 3)mtp = 10;
   Comment("");
   ObjectsDelete();
   RectLabelCreate(pref+"_RectLabel", 108, 68, 106, 66);
   LabelCreate(    pref+"_LabelRisk", 70, 48,  3,      "Risk:", "Arial", FNT);
   EditCreate(     pref+"_EditRisk",  64, 66, 58, 18, RISK);
   ButtonCreate(   pref+"_TR",        104, 46, 100, 20, 3, "send order", "Arial", FNT, clrBlack, C'33,218,51');
   ButtonCreate(   pref+"_CLS",       104, 24, 100, 20, 3, "close orders", "Arial", FNT, clrBlack, clrRed);
//---
   return(INIT_SUCCEEDED);
}
//+---------------------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   ObjectsDelete();
}
//+---------------------------------------------------------------------------------+
void OnTick(){
//---
   if(ObjectGetInteger(ChartID(), pref+"_TR", OBJPROP_STATE)){
      Trade();
      ObjectSetInteger(ChartID(), pref+"_TR", OBJPROP_STATE, false);
   }
   if(ObjectGetInteger(ChartID(), pref+"_CLS", OBJPROP_STATE)){
      trade.CloseTrades();
      trade.DeletePendings();
      ObjectSetInteger(ChartID(), pref+"_CLS", OBJPROP_STATE, false);
   }
}
//+---------------------------------------------------------------------------------+
void OnChartEvent(const int id,         // идентификатор события   
                  const long& lparam,   // параметр события типа long 
                  const double& dparam, // параметр события типа double 
                  const string& sparam){// параметр события типа string
   static bool t_move = false;
   static bool s_move = false;
   static bool p_move = false;
   
   static datetime time;
   static double price = 0.0;
   static int window = 0;
   
   //Если нажали клавишу P и двигаем мышкой, то перемещается линия price_level
   //Если нажали клавишу T и двигаем мышкой, то перемещается линия tp_level
   //Если нажали клавишу S и двигаем мышкой, то перемещается линия sl_level
   //Если нажали ЛКМ, то линия привязывается к текущему уровню и флаги P, T и S сбрасываются
   ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, window, time, price);
   if(id == CHARTEVENT_KEYDOWN){
      if(lparam == StringToToken(HK_TP)){
         string n = t_line;
         t_move = true;s_move = false; p_move = false; 
         if(ObjectFind(ChartID(), n) != -1) ObjectDelete(ChartID(), n);
         else HLineCreate(n, price, clrGreen, "take profit");
      }
      else if(lparam == StringToToken(HK_SL)){
         string n = s_line;
         t_move = false;s_move = true;p_move = false;
         if(ObjectFind(ChartID(), n) != -1) ObjectDelete(ChartID(), n);
         else HLineCreate(n, price, clrRed ,"stop loss");
      }
      else if(lparam == StringToToken(HK_PR)){
         string n = p_line;
         t_move = false;s_move = false;p_move = true;
         if(ObjectFind(ChartID(), n) != -1) ObjectDelete(ChartID(), n);
         else HLineCreate(n, price, clrOrange, "price open");
      }      
   }
   if(id == CHARTEVENT_MOUSE_MOVE){            
      if(t_move){
         LineMove(t_line,price);
      }
      if(s_move){
         LineMove(s_line,price);
      }  
      if(p_move){
         LineMove(p_line,price);
      }     
   }
   
   if(id == CHARTEVENT_CLICK && (t_move || s_move || p_move)){
      t_move = false;
      s_move = false;
      p_move = false;
   }   
}
//+------------------------------------------------------------------+

long StringToToken(const string& s){
   if(s[0] == '0') return 48;
   if(s[0] == '1') return 49;
   if(s[0] == '2') return 50;
   if(s[0] == '3') return 51;
   if(s[0] == '4') return 52;
   if(s[0] == '5') return 53;
   if(s[0] == '6') return 54;
   if(s[0] == '7') return 55;
   if(s[0] == '8') return 56;
   if(s[0] == '9') return 57;
   if(s[0] == 'A' || s[0] == 'a') return 65;
   if(s[0] == 'B' || s[0] == 'b') return 66;
   if(s[0] == 'C' || s[0] == 'c') return 67;
   if(s[0] == 'D' || s[0] == 'd') return 68;
   if(s[0] == 'E' || s[0] == 'e') return 69;
   if(s[0] == 'F' || s[0] == 'f') return 70;
   if(s[0] == 'G' || s[0] == 'g') return 71;
   if(s[0] == 'H' || s[0] == 'h') return 72;
   if(s[0] == 'I' || s[0] == 'i') return 73;
   if(s[0] == 'J' || s[0] == 'j') return 74;
   if(s[0] == 'K' || s[0] == 'k') return 75;
   if(s[0] == 'L' || s[0] == 'l') return 76;
   if(s[0] == 'M' || s[0] == 'm') return 77;
   if(s[0] == 'N' || s[0] == 'n') return 78;
   if(s[0] == 'O' || s[0] == 'o') return 79;
   if(s[0] == 'P' || s[0] == 'p') return 80;
   if(s[0] == 'Q' || s[0] == 'q') return 81;
   if(s[0] == 'R' || s[0] == 'r') return 82;
   if(s[0] == 'S' || s[0] == 's') return 83;
   if(s[0] == 'T' || s[0] == 't') return 84;
   if(s[0] == 'U' || s[0] == 'u') return 85;
   if(s[0] == 'V' || s[0] == 'v') return 86;
   if(s[0] == 'W' || s[0] == 'w') return 87;
   if(s[0] == 'X' || s[0] == 'x') return 88;
   if(s[0] == 'Y' || s[0] == 'y') return 89;
   if(s[0] == 'Z' || s[0] == 'z') return 90;
   return -1;
}

//+------------------------------------------------------------------+
  
//Удаляет все объекты, используемые этим советником
// ot = общее количество всех объектов
// on = имя объекта
void ObjectsDelete(){
   int ot = ObjectsTotal();
   string on = "";
   if(ot > 0){
      for(int i = ot-1; i>=0; i--){
         on = ObjectName(ChartID(), i);
         if(StringFind(on, pref)!= -1) ObjectDelete(ChartID(), on);
      }
   }
}
//+------------------------------------------------------------------+
bool Trade(){
   
   string sr = ObjectGetString(ChartID(), pref+"_EditRisk", OBJPROP_TEXT);
   StringReplace(sr, ",", ".");
   
   double tp   = NormalizeDouble(ObjectGetDouble(ChartID(), t_line, OBJPROP_PRICE), Digits());
   double sl   = NormalizeDouble(ObjectGetDouble(ChartID(), s_line, OBJPROP_PRICE), Digits());
   double pr   = NormalizeDouble(ObjectGetDouble(ChartID(), p_line, OBJPROP_PRICE), Digits());
   
   double risk = sl == 0.0?0.0:NormalizeDouble(StringToDouble(sr), 1);
   int    pts = 1;
   
   //Рассчитаем количество пунктов до стоплосса
   if(sl != 0.0){
      //Если цена не задана и ордер будет рыночным, то
      if(pr == 0.0){
         if(sl < Bid) pts = (int)((Ask-sl)/Point());
         else if(sl > Ask) pts = (int)((sl-Bid)/Point());
      }
      //Если цена задана и будет отложенный ордер, то
      else{
         if(sl < pr) pts = (int)((pr-sl)/Point());
         else if(pr < sl)pts = (int)((sl- pr)/Point());
      }
   }
   
   //1, 2)
   if(tp == 0.0 && sl == 0.0){
      return Wrong("set a stop loss or take profit line");
   }
   
   //(3, 4, 7)
   if(pr == 0.0){
      
      //РИСКА НЕТ
      //3)
      if(sl == 0.0){
         if(tp > Ask) return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         if(tp < Bid) return trade.Sell(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         return Wrong("take profit can't be inside the spread");
      }
      
      //РИСК ЕСТЬ
      //4)
      if(tp == 0.0){
         if(sl < Bid) return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         if(sl > Ask) return trade.Sell(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         return Wrong("stop loss can't be inside the spread");
      }
      
      //7
      if(tp > Ask && sl > Ask){
         return Wrong("take profit and stop loss above the opening price");
      }
      if(tp < Bid && sl < Bid){
         return Wrong("take profit and stop loss below the opening price");
      }
      if(tp > Ask && sl < Bid) return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
      if(tp < Bid && sl > Ask) return trade.Sell(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
      return Wrong("7 E");
   }
   //(5, 6, 8)
   else{
   
      //РИСКА НЕТ
      //5
      if(sl == 0.0){
         if(tp > pr){
            if(pr > Ask)return trade.BuyStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr < Ask)return trade.BuyLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            
            if(pr == Ask)return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         }
         if(tp < pr){
            if(pr < Bid)return trade.SellStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr > Bid)return trade.SellLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr == Bid)return trade.Sell(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         }
         //5 D
         return Wrong("take profit cannot be equal to the opening price");         
      }
      
      //РИСК ЕСТЬ
      //6
      if(tp == 0.0){
         if(sl < pr){
            if(pr > Ask)return trade.BuyStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr < Ask)return trade.BuyLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr == Ask)return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         }
         if(sl > pr){
            if(pr < Bid)return trade.SellStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr > Bid)return trade.SellLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
            if(pr == Bid)return trade.Sell(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
         }
         //6 D
         return Wrong("stop loss cannot be equal to the opening price");
      }
      
      //8 ВСЕ ЛИНИИ НА ГРАФИКЕ
      if(tp == sl || tp == pr || sl == pr)return Wrong("control levels cannot be equal");
      if(tp > pr && sl > pr)return Wrong("take profit and stop loss above the opening price");
      if(tp < pr && sl < pr)return Wrong("take profit and stop loss below the opening price");
      if(tp > pr){
         if(pr > Ask)return trade.BuyStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
         if(pr < Ask)return trade.BuyLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
                     return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
      }
      if(tp < pr){
         if(pr > Bid)return trade.SellLimit(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
         if(pr < Bid)return trade.SellStop(Symbol(), AutoLot(risk, pts), pr, sl, tp, 0);
                     return trade.Buy(Symbol(), AutoLot(risk, pts), sl, tp, SLIPPAGE);
      }
   }
   return false;
}
//+------------------------------------------------------------------+
bool Wrong(const string msg){
   Alert(msg);
   return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//r - риск %, p - пункты до стоплосса
double AutoLot(const double r, const int p){
   double l = MarketInfo(Symbol(), MODE_MINLOT);
   
   l = NormalizeDouble((AccountBalance()/100*r/(p*MarketInfo(Symbol(), MODE_TICKVALUE))), 2);
   
   if(l > MarketInfo(Symbol(), MODE_MAXLOT))l = MarketInfo(Symbol(), MODE_MAXLOT);
   if(l < MarketInfo(Symbol(), MODE_MINLOT))l = MarketInfo(Symbol(), MODE_MINLOT);
   return l;
}
//+------------------------------------------------------------------+
bool HLineCreate(const string          name="HLine",      // имя линии
                 double                price=0,           // цена линии 
                 const color           clr=clrRed,        // цвет линии 
                 const string          text="",           // описание линии
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=false,   // выделить для перемещений 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0){        // приоритет на нажатие мышью 
//--- если цена не задана, то установим ее на уровне текущей цены Bid 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ResetLastError(); 
//--- создадим горизонтальную линию 
   if(ObjectFind(ChartID(), name)!= -1)ObjectDelete(ChartID(), name);
   
   const long chart_ID = 0;
   const int sub_window = 0;
   
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)){ 
      Print(__FUNCTION__, 
            ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID, name,OBJPROP_TEXT, text);
   return(true); 
}
//+------------------------------------------------------------------+
bool LineMove(const string name, const double price){
   return ObjectMove(0,name,0,0,price);
}
//+------------------------------------------------------------------+
bool RectLabelCreate(const string           name="RectLabel",         // имя метки
                     const int              x=0,                      // координата по оси X 
                     const int              y=0,                      // координата по оси Y 
                     const int              width=50,                 // ширина 
                     const int              height=18,                // высота 
                     const color            back_clr=C'87,173,202',   // цвет фона 
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // тип границы 
                     const ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER,// угол графика для привязки 
                     const color            clr=clrGray,              // цвет плоской границы (Flat) 
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы 
                     const int              line_width=1,             // толщина плоской границы 
                     const bool             back=false,               // на заднем плане 
                     const bool             selection=false,          // выделить для перемещений 
                     const bool             hidden=true,              // скрыт в списке объектов 
                     const long             z_order=0)                // приоритет на нажатие мышью 
  { 
  if(ObjectFind(ChartID(), name)!= -1)return true;
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим прямоугольную метку 
   const long chart_ID = 0;
   const int sub_window = 0;
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)){ 
      Print(__FUNCTION__, 
            ": не удалось создать прямоугольную метку! Код ошибки = ",GetLastError()); 
      return(false); 
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true); 
}
//+------------------------------------------------------------------+
bool LabelCreate(const string            name="Label",             // имя метки 
                 const int               x=0,                      // координата по оси X 
                 const int               y=0,                      // координата по оси Y 
                 const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER,// угол графика для привязки 
                 const string            text="Label",             // текст 
                 const string            font="Arial",             // шрифт 
                 const int               font_size=10,             // размер шрифта 
                 const color             clr=clrBlack,             // цвет 
                 const double            angle=0.0,                // наклон текста 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_LOWER,// способ привязки 
                 const bool              back=false,               // на заднем плане 
                 const bool              selection=false,          // выделить для перемещений 
                 const bool              hidden=true,              // скрыт в списке объектов 
                 const long              z_order=0)                // приоритет на нажатие мышью 
{
   if(ObjectFind(ChartID(), name)!= -1)return true;
   const long chart_ID = 0;
   const int sub_window = 0;
   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)){ 
      Print(__FUNCTION__, 
            ": не удалось создать текстовую метку! Код ошибки = ",GetLastError()); 
      return(false); 
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true); 
}
//+------------------------------------------------------------------+
bool EditCreate(const string           name="Edit",              // имя объекта 
                const int              x=0,                      // координата по оси X 
                const int              y=0,                      // координата по оси Y 
                const int              width=50,                 // ширина 
                const int              height=18,                // высота 
                const string           text="Text",              // текст 
                const string           font="Arial",             // шрифт 
                const int              font_size=10,             // размер шрифта 
                const ENUM_ALIGN_MODE  align=ALIGN_RIGHT,        // способ выравнивания 
                const bool             read_only=false,          // возможность редактировать 
                const ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER,// угол графика для привязки 
                const color            clr=clrBlack,             // цвет текста 
                const color            back_clr=clrWhite,        // цвет фона 
                const color            border_clr=clrNONE,       // цвет границы 
                const bool             back=false,               // на заднем плане 
                const bool             selection=false,          // выделить для перемещений 
                const bool             hidden=true,              // скрыт в списке объектов 
                const long             z_order=0)                // приоритет на нажатие мышью 
{
   if(ObjectFind(ChartID(), name)!= -1)return true;
   const long chart_ID = 0;
   const int sub_window = 0;
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим поле ввода 
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать объект \"Поле ввода\"! Код ошибки = ",GetLastError()); 
      return(false); 
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true); 
  }
  //+------------------------------------------------------------------+
bool ButtonCreate(const string            name="Button",            // имя кнопки 
                  const int               x=0,                      // координата по оси X 
                  const int               y=0,                      // координата по оси Y 
                  const int               width=50,                 // ширина кнопки 
                  const int               height=18,                // высота кнопки 
                  const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER,// угол графика для привязки 
                  const string            text="Button",            // текст 
                  const string            font="Arial",             // шрифт 
                  const int               font_size=10,             // размер шрифта 
                  const color             clr=clrBlack,             // цвет текста 
                  const color             back_clr=C'236,233,216',  // цвет фона 
                  const color             border_clr=clrNONE,       // цвет границы 
                  const bool              state=false,              // нажата/отжата 
                  const bool              back=false,               // на заднем плане 
                  const bool              selection=false,          // выделить для перемещений 
                  const bool              hidden=true,              // скрыт в списке объектов 
                  const long              z_order=0)                // приоритет на нажатие мышью 
{
   if(ObjectFind(ChartID(), name)!= -1)return true;
   const long chart_ID = 0;
   const int sub_window = 0;
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим кнопку 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать кнопку! Код ошибки = ",GetLastError()); 
      return(false); 
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true); 
}