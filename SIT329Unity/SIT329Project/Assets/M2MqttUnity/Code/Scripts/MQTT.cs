

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;
using M2MqttUnity;

/// Adapted from the  (https://github.com/eclipse/paho.mqtt.m2mqtt),

namespace M2MqttUnity.Examples
{

    public class MQTT : M2MqttUnityClient
    {

        protected override void OnConnecting()
        {
            base.OnConnecting();
            Console.WriteLine("Connecting to broker on " + brokerAddress + ":" + brokerPort.ToString() + "...\n");
        }

        protected override void OnConnected()
        {
            base.OnConnected();
            Console.WriteLine("Connected to broker on " + brokerAddress + "\n");
        }

        protected override void SubscribeTopics()
        {
            client.Subscribe(new string[] { "SIT329-Group5", "SIT329-Group5/Button" }, new byte[] { MqttMsgBase.QOS_LEVEL_EXACTLY_ONCE, MqttMsgBase.QOS_LEVEL_EXACTLY_ONCE });
        }

        protected override void UnsubscribeTopics()
        {
            client.Unsubscribe(new string[] { "SIT329-Group5", "SIT329-Group5/Button" });
        }


        protected override void Start()
        {
            Console.WriteLine("Ready.");
            base.Start();
        }


        protected override void DecodeMessage(string topic, byte[] message)
        {
            string msg = System.Text.Encoding.UTF8.GetString(message);
            Debug.Log("Received: " + msg + " On Topic: " + topic);
            
            if (topic.ToString() == "SIT329-Group5/Button")
            {
                Debug.Log("Button Message Recieved, checking input: ");
                if (msg == "1") {
                    Debug.Log("Button Pushed");
                    base.Jumping();
                }
                else
                {
                 
                    Debug.Log("Button Released");
                    base.Standing();
                }
                
            }
        }


        protected override void Update()
        {
            base.Update(); // call ProcessMqttEvents()
        }

        private void OnDestroy()
        {
            Disconnect();
        }

        private void OnValidate()
        {

        }
    }
}
