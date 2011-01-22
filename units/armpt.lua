unitDef = {
  unitname               = [[armpt]],
  name                   = [[Skeeter]],
  description            = [[Patrol Boat (Scout/Raider)]],
  acceleration           = 0.0984,
  bmcode                 = [[1]],
  brakeRate              = 0.0475,
  buildCostEnergy        = 120,
  buildCostMetal         = 120,
  builder                = false,
  buildPic               = [[ARMPT.png]],
  buildTime              = 120,
  canAttack              = true,
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  canstop                = [[1]],
  category               = [[SHIP]],
  collisionVolumeOffsets = [[0 3 -3]],
  collisionVolumeScales  = [[28 28 65]],
  collisionVolumeTest    = 1,
  collisionVolumeType    = [[ellipsoid]],
  corpse                 = [[DEAD]],

  customParams           = {
    description_fr = [[Navire de Patrouille Éclaireur et Anti-Air]],
    helptext       = [[Cheap, fast, and fragile, this Patrol Boat is good as a raider and spotting for longer-ranged ships. It lacks the firepower or armor for brawling.]],
    helptext_fr    = [[Pas cher, rapide et peu solide, voici venir le Skeeter et ses canons laser. Utile en début de conflit ou en tant qu'éclaireur son blindage le rends trcs vite obsolcte.]],
  },

  defaultmissiontype     = [[Standby]],
  explodeAs              = [[SMALL_UNITEX]],
  floater                = true,
  footprintX             = 3,
  footprintZ             = 3,
  iconType               = [[scoutboat]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  maneuverleashlength    = [[640]],
  mass                   = 117,
  maxDamage              = 520,
  maxVelocity            = 6.2625,
  minCloakDistance       = 75,
  minWaterDepth          = 5,
  movementClass          = [[BOAT3]],
  moveState              = 0,
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
  objectName             = [[scoutboat.s3o]],
  seismicSignature       = 4,
  selfDestructAs         = [[SMALL_UNITEX]],
  side                   = [[ARM]],
  sightDistance          = 845,
  smoothAnim             = true,
  steeringmode           = [[1]],
  TEDClass               = [[SHIP]],
  turninplace            = 0,
  turnRate               = 698,
  workerTime             = 0,

  weapons                = {

    {
      def                = [[MISSILE]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP LAND SINK SHIP SWIM FLOAT HOVER]],
    },

  },


  weaponDefs             = {

    MINESWEEP = {
      name                    = [[MineSweep]],
      areaOfEffect            = 512,
      avoidFeature            = false,
      avoidFriendly           = false,
      collideFeature          = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 11,
      },

      edgeEffectiveness       = 1,
      explosionGenerator      = [[custom:MINESWEEP]],
      impulseFactor           = 0,
      intensity               = 0,
      interceptedByShieldType = 0,
      lineOfSight             = false,
      noSelfDamage            = true,
      paralyzer               = true,
      paralyzeTime            = 10,
      range                   = 300,
      reloadtime              = 3,
      renderType              = 4,
      tolerance               = 32367,
      turret                  = false,
      weaponTimer             = 0.1,
      weaponType              = [[Cannon]],
      weaponVelocity          = 1024,
    },


    MISSILE   = {
      name                    = [[Light Missile]],
      areaOfEffect            = 8,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargetting      = 1,

      damage                  = {
        default = 80,
        planes  = 80,
        subs    = 4,
      },

      explosionGenerator      = [[custom:FLASH2]],
      fireStarter             = 70,
      fixedlauncher           = true,
      flightTime              = 4,
      guidance                = true,
      heightmod               = 0.5,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      lineOfSight             = true,
      metalpershot            = 0,
      model                   = [[wep_m_fury.s3o]],
      noSelfDamage            = true,
      range                   = 270,
      reloadtime              = 1.6,
      renderType              = 1,
      selfprop                = true,
      smokedelay              = [[0.1]],
      smokeTrail              = true,
      soundHit                = [[weapon/missile/rocket_hit]],
      soundStart              = [[weapon/missile/missile_fire7]],
      startsmoke              = [[1]],
      startVelocity           = 300,
      tolerance               = 10000,
      tracks                  = true,
      trajectoryHeight        = 1.2,
      turnRate                = 60000,
      turret                  = true,
      weaponAcceleration      = 350,
      weaponTimer             = 5,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 750,
    },

  },


  featureDefs            = {

    DEAD = {
      description      = [[Wreckage - Skeeter]],
      blocking         = false,
      category         = [[corpses]],
      damage           = 460,
      energy           = 0,
      featureDead      = [[HEAP]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 48,
      object           = [[scoutboat_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 48,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP = {
      description      = [[Debris - Skeeter]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 460,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 4,
      footprintZ       = 4,
      hitdensity       = [[100]],
      metal            = 24,
      object           = [[debris4x4a.s3o]],
      reclaimable      = true,
      reclaimTime      = 24,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ armpt = unitDef })
