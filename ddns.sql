--
-- Table structure for table `ddns`
--

CREATE TABLE IF NOT EXISTS `ddns` (
  `id` varchar(64) NOT NULL,
  `active` tinyint(1) unsigned NOT NULL,
  `hostname` varchar(64) NOT NULL,
  `domain` varchar(50) NOT NULL,
  `MAC_addr` varbinary(17) NOT NULL,
  `last_seen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ddns`
--

INSERT INTO `ddns` (`id`, `company_id`, `active`, `hostname`, `domain`, `MAC_addr`, `last_seen`) VALUES
('1111222233334444555511112222333344445555111122223333444455512345', 1, 'mydevice', 'example.com', 'a716da2001a2', '2015-01-01 00:00:01');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ddns`
--
ALTER TABLE `ddns`
  ADD CONSTRAINT `ddns_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `company` (`company_id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
