# Thinking Scents 

### “An essential oil diffuser that knows what you need and delivers scents to your beloved one.”
---


**Proposed by @roxy-cym, @virgolibra , @VivianKuKu**

* **Video demo:** https://youtube.com/playlist?list=PLA7pHR4F5RG7yEJN9Kg90aQes7j7dtDWt

* **Pitch deck:** https://liveuclac-my.sharepoint.com/:p:/g/personal/ucfncku_ucl_ac_uk/Ec5mqVO9ztFKgKjWk03uMUsBUshD_XR0DNpP1KR7etNDmQ?e=22BfDx

---

### 1. The Motivation for the Thinking Scents

The motivation for building Thinking Scents comes from the frustration at having little interactions between the environments and people when using oil diffusers from the current market. For example, current products can't automatically adjust the scents emitted according to real-time environmental conditions. What’s more, there is no oil diffuser that enables users to share the scents they are using right now with the people they care about. As a result, Thinking Scents wants to rebuild the connections between people and their surrounding environments and their beloved ones by choosing and sharing scents automatically.

In addition, although there are several oil diffusers on the market that can allow users to mix up multiple scents at the same time, most of them are either relatively simple in function or expensive in device per se. However, according to research, using different scents in different weather conditions will bring many benefits to people, especially having a positive effect on improving people's mood. That’s why Thinking Scents will offer competitive pricing at £120 per device including allowing two mobile devices to access the App.

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166908134-1f3f64f8-9e63-476c-9711-186534704360.png">

Fig 1. The comparison of oil diffusers on current market


---

### 2. Product

#### 2-1. Physical Device

The physical device accommodates water tanks and the hardware such as ultrasonic mist makers and the Arduino WiFi board together. In order to allow users to mix up the scents they want, there is only one chimney designed that enables steam to diffuse. Users can add one kind of essential oil to at most three water tanks respectively and control the on/off of each mist maker. There is a wall between the room for water tanks and the other one for hardware making sure steam will not influence the electronic parts. All parts (walls, roofs, base) of the enclosure can be taken apart and reassembled.

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166908533-768f6300-affb-46f7-bbd4-1108b503d34a.png">

Fig 2. The components of the Thinking Scents


#### 2-2. App Development

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166908628-c1ef5419-b50e-41a0-a10a-501ad48bc5c6.png">

Fig 3. The user interfaces (From left to right: Auto mode, Manual mode (standard), Manual mode (percentage), Share mode)

##### a.	Auto mode

In auto mode, the temperature was divided into 3 categories, which are t<15; 15<=t<=25;t>=25 respectively. Moreover, the humidity was divided into two categories: t>15; t<=15. There are six combinations in total.

Different scents will have different functions and features. Based on the features of the six combinations. I selected three scents with different tones: neutral tone-lavender, cold tone-tea tree, and warm tone-sweet orange.

Tea tree will be used in hot weather. It can make people feel relaxed and calm down. Sweet orange will be used in cold weather. It can make people feel energetic and get rid of the cold. Lavender will be used in a moderate environment. It will help people’s minds and bodies calm down. It also will blend with tea tree and sweet orange according to different weather conditions.

Table 1. The environmental conditions and the scents


<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166908727-dc7643c6-5b4f-4be0-b1c1-4ca8a05a5fc8.png">


##### b.	Manual mode

This is a simple flutter application to control the diffuser. The development procedure can be divided into Bluetooth connection, message transceive, and UI design. The Bluetooth functionality is based on the flutter_bluetooth_serial library. It builds an interface for Serial Port Protocol devices. The library supports device discovery, status monitoring, connecting multiple devices, and data transceiving.
The design of the user interface follows the aesthetic and minimalist rules. Figures 3 (second and third from the left) are the main pages to control the diffuser. There is a toggle switch widget at the top of the page to select the mode. The temperature and humidity text boxes show the received real-time sensing data from the DHT sensor. The second toggle switch widget changes the standard mode and percentage mode. The standard mode is to turn on and off directly, while the percentage mode allows the user to customise the percentage of the concentration to create unique mixed scents. A method similar to Pulse-width modulation (PWM) is used. In a regular period, the duty cycle of the mist maker is regarded as the percentage of the scents. For example, to achieve 70% lavender and 40% sweet orange, in ten seconds, the mist maker for lavender is on for 7 seconds and the maker for sweet orange is on for 4 seconds. 


##### c.	Share mode

The idea to implement a share mode among devices is based on MQTT. Each switch has a code to represent the status. For example, ‘s1d’ means the first switch is disabled, and ‘s2e’ means the second switch is enabled. The switch status and sensor data are published to specific topics every two seconds, and other devices can subscribe to receive the message. It can be regarded as the incoming control commands, which are the same as the commands from the app. The same scents can be produced by synchronising the switch status.

---


### 3. How it works

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166908956-8339bab1-9b73-404d-86cc-233f0562c72d.png">

Fig 4. Schematic of the prototype of Thinking Scents


Figure 4 is the schematic of the diffuser system. The objective is to achieve three modes and is based on App control. Therefore, the Arduino Uno Wi-Fi development board is used, which has a built-in WiFi module. The basic idea is to develop a mobile application that users can turn on and off the diffuser, switch three modes and set custom scents combinations. The HC-05 Bluetooth module is used for serial communication with the board, which can transmit and receive massage packages for remotely control. The WiFi module is used to connect to the MQTT broker, so each board can publish the current diffuser status to share and subscribe status of other devices to synchronise the scents. The mist maker transposes the high-frequency sound waves into mechanical energy. The liquid is broken into mist when it exits the surface of the mist maker. There are three mist makers for this product, which are controlled by the Arduino GPIO pins. The GPIO pins have the current limitation as a protection, which affects the power input for each maker. Therefore, a 4-channel relay is used to ensure the operation of the system.



#### 3-1. Control Commands

Table 2. Control Commands

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909056-2900326d-9fea-44b5-aaa7-5ee38dddb21e.png">


Control commands are the key to achieving remote control. Bluetooth serial protocol sends one-byte character at a time. The message is sent according to the interaction from the app and received sequentially by Arduino. Each incoming message is stored in a temporary char array, which will be iterated to retrieve each character by if statements. For example, the percentage means mode setting, and the hashtag means switch status. The third character represents the number of switches, and ‘e’ means enable. The series commands correspond to different instructions, which could convert the changing of a widget status to the signal changing for GPIO pins via Bluetooth.


#### 3-2. Arduino Script

Arduino script contains the functionality of DHT sensor reading, WiFi connection, MQTT connection and command recognition. Command recognition is the key to achieving remote control, which uses a combination of if and switch-case statements to retrieve the receiving messages. The essence of diffuser control is to adjust each switch on and off. Each switch has a boolean variable as a flag. The value will be determined according to the result of the statement, which triggers the voltage level of relevant GPIO pins. The share mode is based on the sharing of switch status. MQTT is used to publish each switch status, and meanwhile, another device status can be subscribed to sync the scents.

---

### 4. Reflection

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909553-6ff41fff-46b0-433c-8ffa-55b976e57c7b.png">

Fig 5. The prototype of the mobile App (left) and the enclosure (right)


#### 4.1 The iteration of the physical device
 
The project has considered the choices between an ultrasonic mist maker and a nebulizing diffuser in the beginning. However, since the nebulizing diffuser will require more essential oil consumption as opposed to the amount for an ultrasonic mist maker within the same period of time and doesn’t have any humidifying effect, the project eventually chose to use ultrasonic mist makers. In addition, the initial idea is to directly soak mist makers into the water; however, it’s hard to fix the mist maker at specific positions while keeping them working as usual, so the cotton sticks and the mist maker holders (built by 3d printing) are used to offer a better usability.

<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909259-4b25a447-74b4-44d1-8f5b-b569d78db360.png">

Fig 6. The initial idea (left) and the final product (right)


<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909693-31d15a0b-a8ed-4738-ad3d-10bb0b9bb62e.png">

Fig 7. The use of cotton sticks and mist maker holders


#### 4.2 Flutter Application
The flutter application, Arduino script and hardware components are integrated, and the performance is tested. The part of functionalities is implemented. Users can select modes, separately control each mist maker and customise the blending of scents. The responding speed is based on the quality of the Bluetooth connection. There is a delay due to message transmission, but the average is less than one second.


<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909798-f25acaed-70f7-4c63-8c38-c2fb720899d2.png">

Fig 8. Topic (ucfnmzz0) in MQTT Explorer

However, the share mode is not fully completed. Currently, the system can upload status to the MQTT broker, as Figure 8 shows, and listen to the specific topic to receive shared messages. By manually publishing the relevant commands to the subscribed topic, the device can turn on and off the mist makers. The further task is to test publishment and subscription among multiple devices.


---

### 5. Future Modification 

#### 5-1. Enclosure and Hardwares

**1.	Add an on/off button on the device:** This button will allow users to turn on/off the device and switch between three modes, adding more usability to the application.

**2.	Add water level sensors for each water tank:** Users might benefit from the water level monitors which help remind them to add more water in advance.

**3.	Improve the waterproof level of the enclosure:** The project currently uses polylactic acid (PLA) material to build the enclosure. However, the device has a water leak after running for 30 minutes and the steam also humidifies the room inside the device which might have a negative impact on the mist makers.


<img width="700" alt="image" src="https://user-images.githubusercontent.com/52306317/166909970-cd4c6538-4bb1-407b-a837-ecbd29088ec1.png">

Fig 9. Steam left in the room

**4.	Reallocate the DHT sensor:** The DHT sensor is currently placed inside the house. When the mist makers start emitting water mist, the humidity and temperature inside the device will increase. The humidity and temperature reading will be affected. So in the next version. We will optimise the position of the DHT sensor to improve the accuracy.


**5.	Design and manufacture PCB boards for commercial products:** PCB boards will make the products more stable and plug-and-play.


#### 5-2. App Development

**1.	Adjust the user interface of the App:** The mobile app can receive the DHT readings and display them on the screen but cannot obtain the real-time status of each mist maker under Auto mode and Share mode. The solution is to separate the current single page with a toggle switch ianto three pages for clarity and display the status for each mode.


**2.	Adjust the command type:** The length of the control message can be reduced by using hexadecimal commands instead of commands with character types to increase the transfer speed and reduce the control delay.


**3.	Adjust the communication way:** The share mode is dependent on MQTT and WiFi connection. An improvement is to use the phone’s WiFi instead of Arduino WiFi to reduce the cost and complexity of the device component.










