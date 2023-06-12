Hardware implementation through Python.

## Getting Started

<pre>
<code>
Components
- Raspberry Pi Model 4B
- 7 -Segment
- SN74LS47N
- Wire LED
- 2ch Relay Module
</code>
</pre>

1. Prepare the components and connect them together</br>
(Reference materials for connection can be found through the link below)</br>
[Go to Reference](https://www.hackster.io/506312/smart-traffic-light-alarm-app-c4a34a?auth_token=c9b10a983769b5a342a59064044314e8)

2. install Python3
<pre>
<code>
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install -y build-essential tk-dev libncurses5-dev
$ wget https://www.python.org/ftp/python/3.7.13/Python-3.7.13.tgz
$ sudo tar zxf Python-3.7.13.tgz
$ cd Python-3.7.13
$ sudo ./configure --enable-optimizations
$ sudo make altinstall
</code>
</pre>

(It is not necessary to install Python 3.7.13, but it is recommended to install Python 3 or higher)

2. Download "onem2m_raspberry_pi.py" and install on Raspberry Pi

3. Go to the installation

4. Topic and IP address need to be configured for each environment

5. Execute via Python command
<pre>
<code>
$ python onem2m_raspberry_pi.py
</code>
</pre>

## Special note
> <span style="color:orange">- The connection of the module does not have to follow the GPIO specified in the code.</span></br>
> <span style="color:orange">- If the package is not executed due to missing package, it is necessary to install the corresponding package based on the latest standard.</span>