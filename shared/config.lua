Config = {}
 
Config.Framework = 'auto' -- auto | qbcore | qbox | esx | standalone
Config.FrameworkFolder = 'qb-core' -- legacy override for qb-core/es_extended export name
Config.Inventory = 'auto' -- auto | qb-inventory | ox_inventory | esx_inventory | qs-inventory | standalone
Config.InventoryImagesLocation = 'auto' -- auto uses inventory defaults
Config.FuelSystem = 'auto' -- auto | LegacyFuel | CDN-Fuel | ox_fuel | qb-fuel | none
Config.Debug = false

Config.npcs = {
    {
        name = "Tony Soprano", -- NPC name
		hide = true, --Hide NPC from the tablet list 
        private = true, --If you wanna make the NPC Private, meaning it wont show on the Tablet unless they speak with him!
        text = "Fratello, Wanna rob a bank?", -- Initial dialogue text
        domain = "Fleeca Heist", -- Domain / Domain is what the reputation system relies on
        ped = "mp_m_bogdangoon", -- NPC Model
        scenario = "WORLD_HUMAN_STAND_MOBILE", -- NPC Scenario
        police = true, -- Indicates whether the NPC is accessible to Police workers
        coords = vector4(-1021.4726, -733.4947, 18.9645, 33.6408), -- Coordinates
        options = { -- Dialogue options available when interacting with the NPC
            {
                label = "Tell me more!", -- Option text
                requiredrep = 10, -- Required reputation to select this option
                type = "add", -- Type: command/client/server/add ~ In this case add means that this btn would bring more dialogue
                event = "",
                data = { -- Additional data provided when this option is chosen
                    text = "Ok you gotta do it by night when it's quiet, you'd have 15mins to get everything set in place and time...",
                    options = {
                        {
                            label = "Sounds good", -- Subsequent option
                            event = "exter-contacts:event1", -- Event triggered by this option
                            type = "client", -- Interaction type
                            args = {} -- Arguments passed to the event
                        },
                        {
                            label = "Leave conversation", -- Option to leave the conversation
                            event = "", -- No event triggered
                            type = "none", -- Indicates no further interaction
                            args = {} -- No arguments
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Leave conversation", -- Simple option to exit interaction
                requiredrep = 0, -- No reputation requirement
                type = "command", -- Type: command/client/server/add
                event = "e c", -- Event triggered
                args = {}
            },
        }
    },

    {
        name = "Luna Lux",
        private = true, 
        text = "What are you interested in?", 
        domain = "Mooonshine", 
		hide = true,
        ped = "a_m_m_salton_01", 
        scenario = "WORLD_HUMAN_STAND_IMPATIENT", 
        police = true, 
        coords = vector4(-36.7925, 1947.6371, 189.1862, 208.7339),
        options = { 
            {
                label = "Package Product",
                requiredrep = 0,
                type = "add",
                event = "",
                data = {
                    text = "How good is your product?",
                    options = {
                        {
                            label = "Average and Lower",
                            requiredrep = 0,
                            type = "add",
                            event = "",
                            data = {
                                text = "Low quality product doesn't sell for much, but the customers are too drunk to remember they ordered it so you can take your time delivering it. Hand them over and I'll package them for you to hand deliver.",
                                options = {
                                    {
                                        label = "Package For Delivery",
                                        requiredrep = 0,
                                        event = "exter-moonshine:server:Package",
                                        type = "server",
                                        args = {"below-avg"} 
                                    },
                                    {
                                        label = "Leave conversation",
                                        requiredrep = 0,
                                        type = "none",
                                        event = "",
                                        args = {} 
                                    },
                                }
                            },
                            args = {} 
                        },
                        {
                            label = "Above Average Plus",
                            requiredrep = 0,
                            type = "add",
                            event = "",
                            data = {
                                text = "High quality product sells for a hefty price, but the customers are picky and want it fast. Hand them over and I'll package them for you to hand deliver.",
                                options = {
                                    {
                                        label = "Package For Delivery",
                                        requiredrep = 0,
                                        event = "exter-moonshine:server:premiumStart",
                                        type = "server",
                                        args = {} 
                                    },
                                    {
                                        label = "Leave conversation",
                                        requiredrep = 0,
                                        type = "none",
                                        event = "",
                                        args = {} 
                                    },
                                }
                            },
                            args = {}  
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                event = "",
                args = {} 
            },
        }
    },
    -- More NPCs can be added following the same structure
    {
        name = "Fer' Sherman",
        private = false, 
        text = "This lake's a beauty, isn't she? I spent most of my time out here fishing, it's a great way to relax and pass the time. I've got some spare equipment for sale if you want to give it a try.", 
        domain = "Fishing", 
        ped = "cs_old_man2", 
        scenario = "", 
        police = true, 
        coords = vector4(1303.9150, 4229.0024, 32.9087, 40.4492), 
        options = { 
            {
                label = "Buy Equipment", 
                requiredrep = 0, --required rep to even open the shop
                type = "shop", 
                items = {
                    {
                        name = "fishingrod",
                        description = "Tools",
                        requiredrep = 0,
                        price = 150
                    },
                    {
                        name = "fishbait",
                        description = "Tools",
                        requiredrep = 0,
                        price = 20
                    },
                
                },
                event = "",
                args = {}
            },
            {
                label = "Sell Fish",
                requiredrep = 0,
                type = "server",
                event = "exter-fishing:sellFishes",
                args = {} 
            },
            {
                label = "View Leaderboard",
                requiredrep = 0,
                type = "client",
                event = "exter-fishing:showLeaderboard",
                args = {} 
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                event = "",
                args = {} 
            },
        }
    },

    {
        name = "Max Mosley's",
        private = false, 
        text = "Hey there, I don't think we've crossed paths before. I'm Max, and I'm in charge of the Mosley's. You thinkin' about joining our crew?", 
        domain = "Mosley's", 
        ped = "s_m_m_autoshop_01", 
        scenario = "WORLD_HUMAN_CLIPBOARD", 
        police = true, 
        coords = vector4(-37.6105, -1677.4086, 28.4917, 142.1383), 
        options = { 
            {
                label = "I want to work",
                requiredrep = 0, 
                type = "add",
                event = "",
                data = {
                    text = "Ready for a day of hard work?",
                    options = {
                        {
                            label = "Mosleys (In/Out)", 
                            event = "exter-mosleyjob:cl:init", 
                            type = "client",
                            args = {}
                        },
                        {
                            label = "Leave conversation", 
                            event = "", 
                            type = "none",
                            args = {}
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Efficiency",
                requiredrep = 0, 
                type = "add",
                event = "",
                data = {
                    text = "Come back in the next update.",
                    options = {
                        {
                            label = "Leave conversation", 
                            event = "", 
                            type = "none",
                            args = {}
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Mechanic",
                requiredrep = 0, 
                type = "add",
                event = "",
                data = {
                    text = "Hey there! Interested in a gig as a mechanic?",
                    options = {
                        {
                            label = "I'm ready", 
                            event = "", 
                            type = "none",
                            args = {}
                        },
                        {
                            label = "Leave conversation", 
                            event = "", 
                            type = "none",
                            args = {}
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Open Shop", 
                requiredrep = 0,
                type = "shop", 
                items = {
                    {
                        name = "wheel",
                        description = "Tools",
                        requiredrep = 0,
                        price = 30
                    },
                    {
                        name = "carpolish",
                        description = "Tools",
                        requiredrep = 0,
                        price = 15
                    },
                
                },
                event = "",
                args = {}
            }
        }
    }, 
    {
        name = "Joaquim Silva",
        private = true, 
		hide = true,
        text = "Bandages? I have..", 
        domain = "Emergency", 
        ped = "ig_jewelass", 
        scenario = "WORLD_HUMAN_STAND_MOBILE", 
        police = true, 
        coords = vector4(336.6038, -1403.1871, 31.5092, 357.0313), 
        options = { 
            {
                label = "Open shop", 
                requiredrep = 0, --required rep to even open the shop
                type = "shop", 
                items = {
                    {
                        name = "bandage",
                        description = "Health",
                        requiredrep = 0, --required rep to buy the item
                        price = 150
                    },
                    {
                        name = "water_bottle",
                        description = "Health",
                        requiredrep = 10,
                        price = 50
                    }
                },
                event = "", -- Event triggered
                args = {}
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                event = "",
                args = {} 
            },
        }
    },

    {
        name = "Daniel Armstrong",
        text = "Hey, I reckon we haven't crossed paths yet. I'm Daniel, and I'm in charge of the Gruppe 6 security team. Are you considering becoming part of our crew, or are you just here to monitor your advancement as a security truck specialist?",
        domain = "Gruppe 6",
        ped = "s_m_m_armoured_02",
        scenario = "WORLD_HUMAN_LEANING",
        police = true,
        coords = vector4(-27.7622, -661.3454, 32.4804, 185.3856),
        options = {
            {
                label = "I want to work",
                requiredrep = 0,
                type = "add",
                event = "",
                data = {
                    text = "Ready for a day of hard work?",
                    options = {
                        {
                            label = "Sign In/Out",
                            requiredrep = 0,
                            event = "exter-gruppe6:npc-Signin",
                            type = "client",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "",
                            type = "none",
                            args = {} 
                        },
                        
                    }
                },
                args = {} 
                
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                event = "",
                args = {} 
            },
            
        }
    }, 
    {
        name = "Nick Fondulis",
        text = "Hello, Im the bank manager here at Maze Bank, overseeing the daily operations and ensuring the smooth functioning of our financial services. Its my responsibility to maintain the integrity and security of our institution. Have you arrived with packages to drop off?",
        domain = "Bank Manager",
        ped = "cs_movpremmale",
        scenario = "WORLD_HUMAN_GUARD_STAND",
        police = true,
		hide = true,
        coords = vector4(-1321.2697, -829.5733, 15.9766, 135.7679), --change this!
        options = {
            {
                label = "Deliver Bags",
                requiredrep = 0,
                type = "client",
                event = "exter-gruppe6job:DeliverBags",
                args = {} 
                
            },
            {
                label = "Complete Deposit",
                requiredrep = 0,
                type = "client",
                event = "exter-gruppe6job:AskCompleteDelivery",
                args = {} 
            },
            
        }
    },

    {
        name = "Leo Earthwell",
        text = "Hi there! I don't believe we've met before. My name's Leo, and I'm the head of Sanitation Services. Are you interested in joining our team? We're always looking for hard-working folks who are passionate about keeping our community clean and tidy!",
        domain = "Sanitation Worker",
        ped = "s_m_y_garbage",
        scenario = "WORLD_HUMAN_GUARD_STAND",
        police = true,
        coords = vector4(-319.6920, -1543.4218, 26.7023, 340.8807), --change this!
        options = {
            {
                label = "Lets talk business",
                requiredrep = 2,
                minrep = 0,
                maxrep = 10,
                type = "add",
                event = "",
                data = {
                    text = "Hey, all set for a day of hard work?",
                    options = {
                        {
                            label = "Sign In",
                            requiredrep = 0,
                            event = "exter-sanitation:jobcheck",
                            type = "server",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "",
                            type = "none",
                            args = {} 
                        },
                        
                    }
                },
                args = {} 
                
            },
            {
                label = "Open shop",
                requiredrep = 0,
                type = "client",
                event = "event",
                args = {} 
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                args = {} 
            },
            
        }
    },

    --Trucking
    {
        name = "Frank Miller",
        text = "Hey there, I don't think we've crossed paths before. I'm Frank and i'm in charge of the Trucking company. You thinkin' about joining our crew, or are you just here to keep an eye on your progress as a truck specialist?",
        domain = "Trucking",
        ped = "s_m_m_postal_01",
        scenario = "WORLD_HUMAN_CLIPBOARD",
        police = true,
        coords = vector4(1185.3397, -3256.7158, 5.0288, 359.5007), --change this!
        options = {
            {
                label = "I want to work",
                requiredrep = 0,
                type = "add",
                event = "",
                data = {
                    text = "Hey, all set for a day of hard work?",
                    options = {
                        {
                            label = "Sign In",
                            requiredrep = 0,
                            event = "exter-trucking:Sign",
                            type = "client",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "",
                            type = "none",
                            args = {} 
                        },
                        
                    }
                },
                args = {} 
                
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                args = {} 
            },
            
        }
    },
    {
        name = "Harry Miller",
		
        text = "Hello, here you can check the stock.",
        domain = "Trucking Delivery",
        ped = "s_m_m_postal_01",
        scenario = "WORLD_HUMAN_CLIPBOARD",
        police = true,
        coords = vector4(56.5682, 122.6095, 78.1846, 251.0128),
		hide = true,
        options = {
            {
                label = "Open Stock",
                requiredrep = 0,
                event = "exter-trucking:openStock",
                type = "client",
                args = {} 
            },
            
            {
                label = "Complete Job",
                requiredrep = 0,
                type = "client",
                event = "exter-trucking:AskCompleteDelivery",
                args = {} 
            },
			{
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                args = {} 
            },
            
        }
    },

    --Lumberjack
    {
        name = "Axel Woodstone",
        text = "Hey there, I don't believe we've met before. My name's Axel, and I run this lumberyard. Are you interested in joining our team or just here to track your progress as a lumberjack?",
        domain = "Lumberjack",
        ped = "a_m_m_hillbilly_01",
        scenario = "WORLD_HUMAN_BUM_STANDING",
        police = true,
        coords = vector4(-580.5613, 5368.8198, 69.3830, 340.4991),
        options = {
            {
                label = "I want to work",
                requiredrep = 0,
                type = "add",
                event = "",
                data = {
                    text = "Ready for a day of hard work?",
                    options = {
                        {
                            label = "Sign In/Out",
                            requiredrep = 0,
                            event = "exter-lumberjack:Sign",
                            type = "client",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "",
                            type = "none",
                            args = {} 
                        },
                        
                    }
                },
                args = {} 
                
            },
            {
                label = "Open Shop", 
                requiredrep = 0, --required rep to even open the shop
                type = "shop", 
                items = {
                    {
                        name = "axe",
                        description = "Tools",
                        requiredrep = 0,
                        price = 350
                    },
                
                },
                event = "",
                args = {}
            },
            {
                label = "Sell",
                requiredrep = 0,
                event = "exter-lumberjack:sellWood",
                type = "server",
                args = {} 
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                args = {} 
            },
            
        }
    },

    {
        name = "Niko Bellic",
        text = "Hey gearhead! I've got a lead on some quality rides. I'm your go-to guy for the chopping scene, and there's a job that's perfect for a pro like you. High-quality wheels, no fuss, and a solid payday at the finish line. I've got the details covered - just go along with it. Keep it quiet, bypass those alarms, and let's score big without making too much noise.",
        domain = "Chop Shop",
        ped = "a_m_m_hillbilly_01",
        scenario = "WORLD_HUMAN_SMOKING_POT",
        police = true,
        coords = vector4(962.0398, -1826.5734, 30.2255, 271.2543),
        options = {
            {
                label = "I want to work",
                requiredrep = 0,
                type = "add",
                event = "",
                data = {
                    text = "Ready for a day of hard work?",
                    options = {
                        {
                            label = "Sign In/Out",
                            requiredrep = 0,
                            event = "",
                            type = "client",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "",
                            type = "none",
                            args = {} 
                        },
                        
                    }
                },
                args = {} 
                
            },
            {
                label = "Open Shop", 
                requiredrep = 0, --required rep to even open the shop
                type = "shop", 
                items = {
                    {
                        name = "freqradar",
                        description = "Tools",
                        requiredrep = 0,
                        price = 5000
                    },
                    {
                        name = "ugchip",
                        description = "Tools",
                        requiredrep = 0,
                        price = 20000
                    },
                    {
                        name = "hackingdevice",
                        description = "Tools",
                        requiredrep = 0,
                        price = 10000
                    },
                
                },
                event = "",
                args = {}
            },
            {
                label = "Leave conversation",
                requiredrep = 0,
                type = "none",
                args = {} 
            },
            
        }
    },
}
