#include <QDebug>
#include <cmath>

#include "MAVLinkSimulationMAV.h"

MAVLinkSimulationMAV::MAVLinkSimulationMAV(MAVLinkSimulationLink *parent, int systemid) :
    QObject(parent),
    link(parent),
    planner(parent, systemid),
    systemid(systemid),
    timer25Hz(0),
    timer10Hz(0),
    timer1Hz(0),
    latitude(47.376389),
    longitude(8.548056),
    altitude(0.0),
    x(8.548056),
    y(47.376389),
    z(550),
    roll(0.0),
    pitch(0.0),
    yaw(0.0),
    globalNavigation(true),
    firstWP(false),
    previousSPX(8.548056),
    previousSPY(47.376389),
    previousSPZ(550),
    previousSPYaw(0.0),
    nextSPX(8.548056),
    nextSPY(47.376389),
    nextSPZ(550),
    nextSPYaw(0.0)
{
    // Please note: The waypoint planner is running
    connect(&mainloopTimer, SIGNAL(timeout()), this, SLOT(mainloop()));
    connect(&planner, SIGNAL(messageSent(mavlink_message_t)), this, SLOT(handleMessage(mavlink_message_t)));
    connect(link, SIGNAL(messageReceived(mavlink_message_t)), this, SLOT(handleMessage(mavlink_message_t)));
    mainloopTimer.start(20);
    mainloop();
}

void MAVLinkSimulationMAV::mainloop()
{
    // Calculate new simulator values
//    double maxSpeed = 0.0001; // rad/s in earth coordinate frame

//        double xNew = // (nextSPX - previousSPX)

    // 1 Hz execution
    if (timer1Hz <= 0)
    {
        mavlink_message_t msg;
        mavlink_msg_heartbeat_pack(systemid, MAV_COMP_ID_IMU, &msg, MAV_FIXED_WING, MAV_AUTOPILOT_PIXHAWK);
        link->sendMAVLinkMessage(&msg);
        planner.handleMessage(msg);
        timer1Hz = 50;
    }

    // 10 Hz execution
    if (timer10Hz <= 0)
    {
        if (!firstWP)
        {
            double radPer100ms = 0.0002;
            double altPer100ms = 0.1;
            double xm = (nextSPX - x);
            double ym = (nextSPY - y);
            double zm = (nextSPZ - z);

            float zsign = (zm < 0) ? -1.0f : 1.0f;

            //float trueyaw = atan2f(xm, ym);

            yaw = yaw*0.9 + 0.1*atan2f(xm, ym);

            qDebug() << "SIMULATION MAV: x:" << xm << "y:" << ym << "z:" << zm << "yaw:" << yaw;

            if (sqrt(xm*xm+ym*ym) > 0.0001)
            {
                x += cos(yaw)*radPer100ms;
                y += sin(yaw)*radPer100ms;
                z += altPer100ms*zsign;
            }

            //if (xm < 0.001) xm
        }
        else
        {
            x = nextSPX;
            y = nextSPY;
            z = nextSPZ;
            firstWP = false;
            qDebug() << "INIT STEP";
        }


        mavlink_message_t msg;
        mavlink_global_position_int_t pos;
        pos.alt = z*1000.0;
        pos.lat = y*1E7;
        pos.lon = x*1E7;
        pos.vx = 0;
        pos.vy = 0;
        pos.vz = 0;
        mavlink_msg_global_position_int_encode(systemid, MAV_COMP_ID_IMU, &msg, &pos);
        link->sendMAVLinkMessage(&msg);
        planner.handleMessage(msg);
        mavlink_attitude_t attitude;
        attitude.roll = 0.0f;
        attitude.pitch = 0.0f;
        attitude.yaw = yaw;

        qDebug() << "YAW" << yaw;

        mavlink_msg_attitude_encode(systemid, MAV_COMP_ID_IMU, &msg, &attitude);
        link->sendMAVLinkMessage(&msg);
        timer10Hz = 5;
    }

    // 25 Hz execution
    if (timer25Hz <= 0)
    {
        timer25Hz = 2;
    }

    timer1Hz--;
    timer10Hz--;
    timer25Hz--;
}

void MAVLinkSimulationMAV::handleMessage(const mavlink_message_t& msg)
{
    //qDebug() << "MAV:" << systemid << "RECEIVED MESSAGE FROM" << msg.sysid << "COMP" << msg.compid;

    switch(msg.msgid)
    {
    case MAVLINK_MSG_ID_ATTITUDE:
        break;
    case MAVLINK_MSG_ID_LOCAL_POSITION_SETPOINT_SET:
        {
            mavlink_local_position_setpoint_set_t sp;
            mavlink_msg_local_position_setpoint_set_decode(&msg, &sp);
            if (sp.target_system == this->systemid)
            {
                previousSPX = nextSPX;
                previousSPY = nextSPY;
                previousSPZ = nextSPZ;
                nextSPX = sp.x;
                nextSPY = sp.y;
                nextSPZ = sp.z;

                // Rotary wing
                //nextSPYaw = sp.yaw;

                // Airplane
                //yaw = atan2(previousSPX-nextSPX, previousSPY-nextSPY);

                //if (!firstWP) firstWP = true;
            }
            //qDebug() << "UPDATED SP:" << "X" << nextSPX << "Y" << nextSPY << "Z" << nextSPZ;
        }
        break;
    }
}