#!/usr/bin/python

import unittest
import mock
import dotfilesinstaller
import platform
import sys
import os
import io

class DotfilesTest(unittest.TestCase):
  def setUp(self):
    dotfilesinstaller.init()
    dotfilesinstaller.cleanUp()

  @mock.patch('platform.system', mock.MagicMock(return_value='Darwin'))
  def testWhenSystemIsDarwinInstallerIdentifiesSystemAsDarwin(self):
    dotfilesinstaller.identifySystem()
    assert(sys.stdout.getvalue().strip().endswith('Darwin'))

  @mock.patch('platform.system', mock.MagicMock(return_value='Linux'))
  def testWhenSystemIsLinuxInstallerIdentifiesSystemAsLinux(self):
    dotfilesinstaller.identifySystem()
    assert(sys.stdout.getvalue().strip().endswith('Linux'))

  @mock.patch('platform.system', mock.MagicMock(return_value='Windows'))
  def testWhenSystemIsWindowsInstallerIdentifiesSystemAsWindowsAndExitsWithCode1(self):
    with self.assertRaises(SystemExit) as cm:
      dotfilesinstaller.identifySystem()
      assert(sys.stdout.getvalue().strip().endswith('not supported!'))
      assertEqual(cm.exception.code, 1)

  def testWhenBashrcExistsInstallerWillDeleteIt(self):
    if not os.path.isfile('bashrc'):
      testbashrc = open('bashrc','w')
      testbashrc.write('Test file...')
      testbashrc.close()
    dotfilesinstaller.cleanUp()
    assert(sys.stdout.getvalue().strip().endswith('bashrc'))
    self.assertFalse(os.path.isfile('bashrc'))

  def testWhenBashrcDoesNotExistInstallerWillNotAttemptDeletion(self):
    if os.path.isfile('bashrc'):
      os.remove('bashrc')
    try:
      dotfilesinstaller.cleanUp()
    except OSError:
      self.fail("Tried to delete nonexistent file!")

  def testBashrcFileStartsWithShebang(self):
    dotfilesinstaller.writeFileHeader()
    with open('bashrc','r') as bashrc:
      self.assertEquals(bashrc.readline(), "#!/bin/bash\n")

  inputFileMock = io.StringIO(u'some_token=some_value\n')
  def testBashInputFileContentsAreWrittenToBashrc(self):
    dotfilesinstaller.writeSection(self.inputFileMock, False)
    foundExpectedResult = False
    mock = self.inputFileMock.getvalue()
    with open('bashrc','r') as bashrc:
      result = bashrc.read()
    self.assertTrue(result in mock)

  def testWhenSymlinkDoesNotExistitGetsCreated(self):
    with open('bar','a') as bar:
      dotfilesinstaller.createSymlink('bar', 'foo')
    createdSymlink = dotfilesinstaller.homeDir + 'foo'
    try:
      os.stat(createdSymlink)
    except OSError:
      self.fail('Symlink ' + createdSymlink + ' not created!')
    os.remove(createdSymlink)
    os.remove('bar')

suite = unittest.TestLoader().loadTestsFromTestCase(DotfilesTest)
unittest.main(module=__name__, buffer=True, exit=False)
