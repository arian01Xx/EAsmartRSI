#property copyright "♥ NOVA NOIR BANK ♥ CEO Arian J. Mio ♥  Wife Zarah Halimi O. ♥ "
#property version   "Zarah y Arian <3"

#include <Trade/Trade.mqh>

CTrade trade;

input double lots=0.1;
input int takeProfit=50;
input int stopLoss=10;

int Rsi;
double RSI[];
double RsiValue;

int OnInit(){
   Rsi = iRSI(_Symbol, PERIOD_M5, 13, PRICE_CLOSE);
   ArraySetAsSeries(RSI, true);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   // Aquí puedes limpiar recursos si es necesario
}

void OnTick(){
   // Obtener los valores actuales de Ask y Bid
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Copiar los valores del indicador RSI
   CopyBuffer(Rsi, 0, 0, 3, RSI);
   RsiValue = RSI[0];
   
   // Normalizar los valores de TP y SL
   double tpB = NormalizeDouble(ask + takeProfit * _Point, _Digits);
   double slB = NormalizeDouble(ask - stopLoss * _Point, _Digits);
   double tpS = NormalizeDouble(bid - takeProfit * _Point, _Digits);
   double slS = NormalizeDouble(bid + stopLoss * _Point, _Digits);

   // Contar las posiciones abiertas en el símbolo actual
   int buyPositions = 0;
   int sellPositions = 0;
   int orders=PositionsTotal();
   for(int i = orders - 1; i >= 0; i--){
      if(PositionSelect(i)){
         if(PositionGetString(POSITION_SYMBOL) == _Symbol){
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               buyPositions++;
            } else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               sellPositions++;
            }
         }
      }
   }
   
   bool openOrderBuy;
   bool openOrderSell;
   
   if(buyPositions<3){
     openOrderBuy=true;
   }else if(buyPositions>=3){
     openOrderBuy=false;
   }
   
   if(sellPositions<3){
     openOrderSell=true;
   }else if(sellPositions>=3){
     openOrderSell=false;
   }
   
   // Abrir una nueva posición de compra si no hay posiciones de compra abiertas
   if(RsiValue > 50){
      if(openOrderBuy==true){
        trade.Buy(lots, _Symbol, ask, slB, tpB);
      }else if(openOrderBuy==false){
        trade.OrderDelete(trade.Buy(lots, _Symbol, ask, slB, tpB));
        
      }
   }

   // Abrir una nueva posición de venta si no hay posiciones de venta abiertas
   if(RsiValue < 50){
      if(openOrderSell==true){
        trade.Sell(lots, _Symbol, bid, slS, tpS);
      }else if(openOrderSell==false){
        trade.OrderDelete(trade.Sell(lots, _Symbol, bid, slS, tpS));
      }
   }
}
