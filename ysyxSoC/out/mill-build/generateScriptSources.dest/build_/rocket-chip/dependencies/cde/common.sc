package build_.`rocket-chip`.dependencies.cde
import _root_.{build_ => $file}
import build_.{package_ => build}
object common {
//MILL_ORIGINAL_FILE_PATH=/home/hjw-arch/ysyx-workbench/ysyxSoC/rocket-chip/dependencies/cde/common.sc
//MILL_USER_CODE_START_MARKER
import mill._
import scalalib._

trait CDEModule
  extends ScalaModule

trait CDETestModule
  extends TestModule
    with ScalaModule
    with TestModule.Utest {

  def cdeModule: CDEModule

  def utestIvy: Dep

  override def moduleDeps = super.moduleDeps ++ Some(cdeModule)

  override def ivyDeps = T(
    super.ivyDeps() ++ Agg(
      utestIvy
    )
  )

  override def defaultCommandName() = "test"
}

}