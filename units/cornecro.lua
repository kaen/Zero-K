unitDef = {
  unitname            = [[cornecro]],
  name                = [[Convict]],
  description         = [[Construction/Shield Support bot, Builds at 5 m/s]],
  acceleration        = 0.5,
  activateWhenBuilt   = true,
  brakeRate           = 0.3,
  buildCostEnergy     = 140,
  buildCostMetal      = 140,
  buildDistance       = 90,
  builder             = true,

  buildoptions        = {
  },

  buildPic            = [[CORNECRO.png]],
  buildTime           = 140,
  canAssist           = true,
  canBuild            = true,
  canMove             = true,
  canPatrol           = true,
  canreclamate        = [[1]],
  category            = [[LAND UNARMED]],
  corpse              = [[DEAD]],

  customParams        = {
    description_bp = [[Robô de construç?o, constrói a 6 m/s]],
    description_es = [[Robot de Construccion, Construye a 6 m/s]],
    description_fr = [[Robot de Construction, Construit ? 6 m/s]],
    description_it = [[Robot da Costruzzione, Costruisce a 6 m/s]],
	description_de = [[Konstruktions, Baut mit 6 M/s]],
    helptext       = [[The Convict is a fairly standard construction bot with a twist: a light shield to defend itself and support allied shieldbots.]],
    helptext_bp    = [[]],
    --helptext_fr    = [[Le Convict tient son nom de sa facult?, comme tous les constructeurs de sa faction, ? r?ssuciter les carcasses du champ de bataille. La Resurrection ne consomme que de l'?nergie, et d?pends du co?t de l'unit? originelle.]],
    --helptext_de    = [[Der Convict ist ein ziemlich normaler Konstruktionsroboter mit einem Vorteil: er kann Leichen wiederbeleben. Zu 120% der ursprünglichen Energiekosten bekommst du eine so gut wie neue Einheit wiederzurück.]],
  },

  energyMake          = 0.15,
  explodeAs           = [[BIG_UNITEX]],
  footprintX          = 2,
  footprintZ          = 2,
  iconType            = [[builder]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  leaveTracks         = true,
  mass                = 132,
  maxDamage           = 650,
  maxSlope            = 36,
  maxVelocity         = 2,
  maxWaterDepth       = 22,
  metalMake           = 0.15,
  minCloakDistance    = 75,
  movementClass       = [[KBOT2]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
  objectName          = [[conbot.s3o]],
  onoffable           = false,
  script			  = [[cornecro.lua]],
  seismicSignature    = 4,
  selfDestructAs      = [[BIG_UNITEX]],
  showNanoSpray       = false,
  side                = [[CORE]],
  sightDistance       = 375,
  smoothAnim          = true,
  trackOffset         = 0,
  trackStrength       = 8,
  trackStretch        = 1,
  trackType           = [[ComTrack]],
  trackWidth          = 22,
  terraformSpeed      = 300,
  turnRate            = 2200,
  upright             = true,
  workerTime          = 5,
  
  weapons             = {

    {
      def = [[SHIELD]],
    },

  },
  
  weaponDefs          = {

    SHIELD      = {
      name                    = [[Energy Shield]],
      craterMult              = 0,

      damage                  = {
        default = 10,
      },

      exteriorShield          = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      shieldAlpha             = 0.2,
      shieldBadColor          = [[1 0.1 0.1]],
      shieldGoodColor         = [[0.1 0.1 1]],
      shieldInterceptType     = 3,
      shieldPower             = 900,
      shieldPowerRegen        = 9,
      shieldPowerRegenEnergy  = 0,
      shieldRadius            = 80,
      shieldRepulser          = false,
      shieldStartingPower     = 600,
      smartShield             = true,
      texture1                = [[shield3mist]],
      visibleShield           = true,
      visibleShieldHitFrames  = 4,
      visibleShieldRepulse    = true,
      weaponType              = [[Shield]],
    },
	
  },

  featureDefs         = {

    DEAD  = {
      description      = [[Wreckage - Convict]],
      blocking         = true,
      category         = [[corpses]],
      damage           = 650,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 56,
      object           = [[conbot_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 56,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Convict]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 650,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 28,
      object           = [[debris2x2a.s3o]],
      reclaimable      = true,
      reclaimTime      = 28,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ cornecro = unitDef })
