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

use MicroBit;
use MicroBit.IOs;


procedure Main is

   package T_IO renames Ada.Text_IO;
   Data      : LSM303.All_Axes_Data;
   Value     : MicroBit.IOs.Analog_Value;
   File_Name : constant String := "log.txt";
   time_s    : Integer := 0;
   F         : Ada.Text_IO.File_Type

begin
   T_IO.Create  (T_IO., Out_File, File_Name);
   Console.Put_Line ("Jumper - starting up ..");

   while time_s < 10_000 loop

      --  Read the accelerometer data
      Data := Accelerometer.Data;

      --  Print the data on the serial port
      Console.Put_Line ("X:" & Data.X'Img & ASCII.HT &
                        "Y:" & Data.Y'Img & ASCII.HT &
                        "Z:" & Data.Z'Img);
         Put_Line (F, "X:" & Data.X'Img & ASCII.HT &
                     "Y:" & Data.Y'Img & ASCII.HT &
                     "Z:" & Data.Z'Img);

      -- Detect Freefall condition: S = sqrt((X^2)+(Y^2)+(Z^2)) == 0
      -- Sample Freefall over some time
      S_Sum := 0; -- to Do: Make S_Sum floating Point
      for i in Integer range 1 .. 10 loop
         S_Value := Ada.Numerics.Elementary_Functions.sqrt(Data.X'Img*Data.X'Img + Data.Y'Img*Data.Y'Img + Data.Y'Img*Data.Y'Img);
         S_Sum := S_Sum + S_Value;
      end loop;
      if (S_Sum / 10) < 0.005 then -- Check if equation is really floating point
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
      time_s := time_s + 50;
   end loop;
   Close(F);
end Main;
