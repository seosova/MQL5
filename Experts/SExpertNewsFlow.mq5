//+------------------------------------------------------------------+
//|                                              SExpertNewsFlow.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input string   file_name_datetime="news_datetime.csv";
input string   file_name_currency="news_currency.csv";
input string   file_name_theme="news_theme.csv";
input string   file_name_impact="news_impact.csv";
input string   file_name_actual="news_actual.csv";
input string   file_name_forecast="news_forecast.csv";
input string   file_name_previous="news_previous.csv";
//--- globe scope
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   NewsFromFile News1(file_name_datetime,file_name_currency,file_name_theme,file_name_impact,file_name_actual,file_name_forecast,file_name_previous);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   NewsFromFile News1(file_name_datetime,file_name_datetime,file_name_datetime,file_name_datetime,file_name_datetime,file_name_datetime,file_name_datetime);
   News1.SetNewsDateTimeHande(1);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
class NewsFromFile
  {
private:
   datetime          m_news_datetime[];
   string            m_news_currency[];
   string            m_news_theme[];
   string            m_news_impact[];
   double            m_news_actual[];
   double            m_news_forecast[];
   double            m_news_previous[];
   int               m_datetime_handle;
   int               m_file_handle;
public:
                     NewsFromFile(string c_file_name_datetime,string c_file_name_currency,string c_file_name_theme,string c_file_name_impact,string c_file_name_actual,string c_file_name_forecast,string c_file_name_previous);
                    ~NewsFromFile(void) {};
   void              ReloadAllNewsFiles(string c_file_name_datetime,string c_file_name_currency,string c_file_name_theme,string c_file_name_impact,string c_file_name_actual,string c_file_name_forecast,string c_file_name_previous);
   datetime          SetNewsDateTimeHande(int i);
   string            GetNewsCurrency(int c_datetime_handle);
   string            GetNewsTheme(int c_datetime_handle);
   string            GetNewsImpact(int c_datetime_handle);
   double            GetNewsActual(int c_datetime_handle);
   double            GetNewsForecast(int c_datetime_handle);
   double            GetNewsPrevious(int c_datetime_handle);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
NewsFromFile::NewsFromFile(string c_file_name_datetime,string c_file_name_currency,string c_file_name_theme,string c_file_name_impact,string c_file_name_actual,string c_file_name_forecast,string c_file_name_previous)
  {
   ResetLastError();
   int line_in_file=0;

//-- Загружаем даты из файла

   m_file_handle=FileOpen(c_file_name_datetime,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      //-- определим количество строк в файле datetime csv
      int i=0;
      while(!FileIsEnding(m_file_handle))
        {
         //-- увеличиваем размер массива какждые 100 строк файла истории
         if(i%3==0)
           {
            ArrayResize(m_news_datetime,i+4,300);
           }
         m_news_datetime[i]=FileReadDatetime(m_file_handle);
         i++;
        }
      line_in_file=i;
     }
   else
     {
      Print("Операция FileOpen файла дат, ошибка ",GetLastError());
     }

//-- Загружаем валюты из файла

   m_file_handle=FileOpen(c_file_name_currency,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_currency,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_currency[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла валют неудачна, ошибка ",GetLastError());
     }

//-- Загружаем текст новости из файла

   m_file_handle=FileOpen(c_file_name_theme,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_theme,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_theme[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла текстов новстей неудачна, ошибка ",GetLastError());
     }

//-- Загружаем уровни воздействия из файла

   m_file_handle=FileOpen(c_file_name_impact,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_impact,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_impact[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла уровней воздействия неудачна, ошибка ",GetLastError());
     }

//-- Загружаем актуальные значения из файла

   m_file_handle=FileOpen(c_file_name_actual,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_actual,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_actual[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла актуальных значений неудачна, ошибка ",GetLastError());
     }

//-- Загружаем прогноз значений из файла

   m_file_handle=FileOpen(c_file_name_forecast,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_forecast,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_forecast[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла прогнозов неудачна, ошибка ",GetLastError());
     }

//-- Загружаем предыдущие значения из файла

   m_file_handle=FileOpen(c_file_name_previous,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_previous,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_previous[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла прогнозов неудачна, ошибка ",GetLastError());
     }

  }
//+------------------------------------------------------------------+
void NewsFromFile::ReloadAllNewsFiles(string c_file_name_datetime,string c_file_name_currency,string c_file_name_theme,string c_file_name_impact,string c_file_name_actual,string c_file_name_forecast,string c_file_name_previous) //-- повторное чтение при загрузке нового файла новостей
  {
   ResetLastError();
   int line_in_file=0;
//--- обнуление массивов данных и хэндла файла на всякий случай   
   ArrayFree(m_news_datetime);
   ArrayFree(m_news_currency);
   ArrayFree(m_news_theme);
   ArrayFree(m_news_impact);
   ArrayFree(m_news_actual);
   ArrayFree(m_news_forecast);
   ArrayFree(m_news_previous);
   m_file_handle=0;

//-- Загружаем даты из файла

   m_file_handle=FileOpen(c_file_name_datetime,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      //-- определим количество строк в файле datetime csv
      int i=0;
      while(!FileIsEnding(m_file_handle))
        {
         //-- увеличиваем размер массива какждые 100 строк файла истории
         if(i%3==0)
           {
            ArrayResize(m_news_datetime,i+4,300);
           }
         m_news_datetime[i]=FileReadDatetime(m_file_handle);
         i++;
        }
      line_in_file=i;
     }
   else
     {
      Print("Операция FileOpen файла дат, ошибка ",GetLastError());
     }

//-- Загружаем валюты из файла

   m_file_handle=FileOpen(c_file_name_currency,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_currency,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_currency[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла валют неудачна, ошибка ",GetLastError());
     }

//-- Загружаем текст новости из файла

   m_file_handle=FileOpen(c_file_name_theme,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_theme,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_theme[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла текстов новстей неудачна, ошибка ",GetLastError());
     }

//-- Загружаем уровни воздействия из файла

   m_file_handle=FileOpen(c_file_name_impact,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_impact,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_impact[i]=FileReadString(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла уровней воздействия неудачна, ошибка ",GetLastError());
     }

//-- Загружаем актуальные значения из файла

   m_file_handle=FileOpen(c_file_name_actual,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_actual,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_actual[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла актуальных значений неудачна, ошибка ",GetLastError());
     }

//-- Загружаем прогноз значений из файла

   m_file_handle=FileOpen(c_file_name_forecast,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_forecast,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_forecast[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла прогнозов неудачна, ошибка ",GetLastError());
     }

//-- Загружаем предыдущие значения из файла

   m_file_handle=FileOpen(c_file_name_previous,FILE_READ|FILE_CSV|FILE_ANSI,CP_UTF8);
   if(m_file_handle!=INVALID_HANDLE)
     {
      int i=0;
      ArrayResize(m_news_previous,line_in_file,3000);
      while(!FileIsEnding(m_file_handle))
        {
         m_news_previous[i]=FileReadDouble(m_file_handle);
         i++;
        }
     }
   else
     {
      Print("Операция FileOpen файла прогнозов неудачна, ошибка ",GetLastError());
     }

  }
//+------------------------------------------------------------------+
datetime NewsFromFile::SetNewsDateTimeHande(int i)
  {
   MqlDateTime dt_struct;
   TimeCurrent(dt_struct);
   datetime newdate=dt_struct.day+dt_struct.mon;
   return (newdate);

  }
//+------------------------------------------------------------------+
//string NewsFromFile::GetNewsCurrency(datetime c_news_datetime)
//  {
//
//   return(m_news_currency[i]);
//  }
//+------------------------------------------------------------------+
