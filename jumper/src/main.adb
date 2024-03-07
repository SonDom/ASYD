------------------------------------------------------------------------------
-- Template                                                                         --
------------------------------------------------------------------------------

with LSM303; use LSM303;

with MicroBit.Display;
with MicroBit.Accelerometer;
with MicroBit.Console;
with MicroBit.IOs;
with MicroBit.Time;
with Ada.Numerics.Elementary_Functions;
with Ada.Float_Text_IO;

use MicroBit;
use MicroBit.IOs;
use ADA.Float_Text_IO;


procedure Main is

   Data : LSM303.All_Axes_Data;
   Value : MicroBit.IOs.Analog_Value;

begin

   Console.Put_Line ("Jumper - starting up ..");

   loop

      --  Read the accelerometer data
      Data := Accelerometer.Data;

      --  Print the data on the serial port
      Console.Put_Line ("X:" & Data.X'Img & ASCII.HT &
                        "Y:" & Data.Y'Img & ASCII.HT &
                        "Z:" & Data.Z'Img);

      -- Detect Freefall condition: S = sqrt((X^2)+(Y^2)+(Z^2)) == 0
      -- Sample Freefall over some time
      
      S_Sum := 0.0; 
      for i in Integer range 1 .. 10 loop
         S_Value := Float(Ada.Numerics.Elementary_Functions.sqrt(Data.X*Data.X + Data.Y*Data.Y + Data.Z*Data.Z));
         S_Sum := S_Sum + S_Value;
      end loop;
      if (S_Sum / 10.0) < 0.005 then -- Check if equation is really floating point
      Console.Put_Line("Freefall detected"); 
      --  Clear the LED matrix
      Display.Clear;

      -- Check, whether we are free floating or not (to be refined ...)
      if -100 < Data.X and Data.X < 100 then
         Display.Display ('0');
      else
         Display.Display ('X');
      end if;

      -- Read analogue pin (could be 0,1,2,3,4, or 10)
      Value := MicroBit.IOs.Analog (2);
      Console.Put_Line ("Value : " & Value'Image);

      -- Set output
      if Value > Analog_Value(200) then
         MicroBit.IOs.Set (12, True);
      else
         MicroBit.IOs.Set (12, False);
      end if;

      Time.Sleep (50);
   end loop;
end Main;
