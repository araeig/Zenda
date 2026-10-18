using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZendaAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddNoteLinks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "EventId",
                table: "Notes",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TaskItemId",
                table: "Notes",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Notes_EventId",
                table: "Notes",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_Notes_TaskItemId",
                table: "Notes",
                column: "TaskItemId");

            migrationBuilder.AddForeignKey(
                name: "FK_Notes_Events_EventId",
                table: "Notes",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Notes_TaskItems_TaskItemId",
                table: "Notes",
                column: "TaskItemId",
                principalTable: "TaskItems",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Notes_Events_EventId",
                table: "Notes");

            migrationBuilder.DropForeignKey(
                name: "FK_Notes_TaskItems_TaskItemId",
                table: "Notes");

            migrationBuilder.DropIndex(
                name: "IX_Notes_EventId",
                table: "Notes");

            migrationBuilder.DropIndex(
                name: "IX_Notes_TaskItemId",
                table: "Notes");

            migrationBuilder.DropColumn(
                name: "EventId",
                table: "Notes");

            migrationBuilder.DropColumn(
                name: "TaskItemId",
                table: "Notes");
        }
    }
}
