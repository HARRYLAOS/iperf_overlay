# iperf_overlay
IPERF is tough to learn, especially for the Field Engineers who go to each customer and they want to do some tests. 
They can definately have a saved text file with the commands but that risks that if the customer asks something specific, they wont be able to perform.
There needs to be a definition of SLA and criteria of acceptance of the service which is covered in this script.
This is the reason this bash code was created.

Credits/Coder: Charilaos "Harry" Christopoulos
LinkedIn: https://www.linkedin.com/in/charilaos-christopoulos/

This special code was created during February 2023 in order to make the IPERF Testing
a walk in the park with automated scripting for the original IPERF3 Script.

This is the -sort of- final version and its based on the IPERF3 Script in order to work properly.

=========================================
Installation Notes:
=========================================
- Place the file test8_final.* on your Desktop.
- Download IPERF3 from https://iperf.fr/download/windows/iperf-3.1.3-win64.zip
- Place the iperf3 installation on C:\iperf-3.1.3-win64\ directory
- Run the executable/bash file from your Desktop after you have modified it to fit the iperf servers.

=========================================
How it works:
=========================================
- The first thing it does is to resolve your public ip address and copies this info in 
a text file. You do not see this process being displayed on your screen. This is important in case of a proxy gateway.
- Next input is asking you about the selection of the IPERF3 Server you want to test against.
Just type the number and press Enter.
- Select the duration for the test from 10 to 60 seconds. Input number and press Enter.
- Select if you want to test the Download or the Upload of this connection by typing the 
appropriate number and press Enter. You can test both but not simultaneously. (Feel free to improve the code!)
- Script starts and takes exactly the specific duration to test the bandwidth. 
Once it concludes the final result will be displayed on your screen and a text file will 
be automatically created on the folder you have placed the executable.
